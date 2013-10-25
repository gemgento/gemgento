### https://github.com/meh/ruby-threadpool

module Gemgento
  class ThreadPool
    class Task
      Timeout = Class.new(Exception)
      Asked = Class.new(Exception)

      attr_reader :pool, :timeout, :exception, :thread, :started_at

      def initialize (pool, *args, &block)
        @pool = pool
        @arguments = args
        @block = block
      end

      def running?;
        @running;
      end

      def finished?;
        @finished;
      end

      def timeout?;
        @timedout;
      end

      def terminated?;
        @terminated;
      end

      def execute (thread)
        return if terminated? || running? || finished?

        @thread = thread
        @running = true
        @started_at = Time.now

        pool.wake_up_timeout

        begin
          @block.call(*@arguments)
        rescue Exception => e
          if e.is_a? Timeout
            @timedout = true
          elsif e.is_a? Asked
            return
          else
            @exception = reason
          end
        end

        @running = false
        @finished = true
        @thread = nil
      end

      def terminate! (exception = Asked)
        return if terminated? || finished? || timeout?

        @terminated = true

        return unless running?

        @thread.raise exception
      end

      def timeout!
        terminate! Timeout
      end

      def timeout_after (time)
        @timeout = time

        pool.timeout_for self, time

        self
      end
    end

    attr_reader :min, :max, :spawned

    def initialize (min, max = nil, &block)
      @min = min
      @max = max || min
      @block = block

      @cond = ConditionVariable.new
      @mutex = Mutex.new

      @todo = []
      @workers = []
      @timeouts = {}

      @spawned = 0
      @waiting = 0
      @shutdown = false
      @trim_requests = 0
      @auto_trim = false

      @mutex.synchronize {
        min.times {
          spawn_thread
        }
      }
    end

    def shutdown?;
      @shutdown;
    end

    def auto_trim?;
      @auto_trim;
    end

    def auto_trim!;
      @auto_trim = true;
    end

    def no_auto_trim!;
      @auto_trim = false;
    end

    def resize (min, max = nil)
      @min = min
      @max = max || min

      trim!
    end

    def backlog
      @mutex.synchronize {
        @todo.length
      }
    end

    def process (*args, &block)
      unless block || @block
        raise ArgumentError, 'you must pass a block'
      end

      task = Task.new(self, *args, &(block || @block))

      @mutex.synchronize {
        raise 'unable to add work while shutting down' if shutdown?

        @todo << task

        if @waiting == 0 && @spawned < @max
          spawn_thread
        end

        @cond.signal
      }

      task
    end

    alias << process

    def trim (force = false)
      @mutex.synchronize {
        if (force || @waiting > 0) && @spawned - @trim_requests > @min
          @trim_requests -= 1
          @cond.signal
        end
      }

      self
    end

    def trim!
      trim true
    end

    def shutdown!
      @mutex.synchronize {
        @shutdown = true
        @cond.broadcast
      }

      wake_up_timeout
    end

    def shutdown
      shutdown!

      join
    end

    def join
      @timeout.join if @timeout

      @workers.first.join until @workers.empty?

      self
    end

    def timeout_for (task, timeout)
      unless @timeout
        spawn_timeout_thread
      end

      @mutex.synchronize {
        @timeouts[task] = timeout

        wake_up_timeout
      }
    end

    def shutdown_after (timeout)
      Thread.new {
        sleep timeout

        shutdown
      }

      self
    end

    def wake_up_timeout
      if @pipes
        @pipes.last.write_nonblock 'x' rescue nil
      end
    end

    private
    def spawn_thread
      @spawned += 1

      thread = Thread.new {
        loop do
          task = @mutex.synchronize {
            if @todo.empty?
              while @todo.empty?
                if @trim_requests > 0
                  @trim_requests -= 1

                  break
                end

                break if shutdown?

                @waiting += 1
                @cond.wait @mutex
                @waiting -= 1

                break !shutdown?
              end or break
            end

            @todo.shift
          } or break

          task.execute(thread)

          break if shutdown?

          trim if auto_trim? && @spawned > @min
        end

        @mutex.synchronize {
          @spawned -= 1
          @workers.delete thread
        }
      }

      @workers << thread

      thread
    end

    def spawn_timeout_thread
      @pipes = IO.pipe
      @timeout = Thread.new {
        loop do
          now = Time.now
          timeout = @timeouts.map { |task, timeout|
            next unless task.started_at

            now - task.started_at + task.timeout
          }.compact.min unless @timeouts.empty?

          readable, = IO.select([@pipes.first], nil, nil, timeout)

          break if shutdown?

          if readable && !readable.empty?
            readable.first.read_nonblock 1024
          end

          now = Time.now
          @timeouts.each { |task, time|
            next if !task.started_at || task.terminated? || task.finished?

            if now > task.started_at + task.timeout
              task.timeout!
            end
          }

          @timeouts.reject! { |task, _| task.terminated? || task.finished? }

          break if shutdown?
        end
      }
    end
  end
end