# Copyright (c) 2005 David Heinemeier Hansson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# module Gemgento
#   module SslRequirement
#     def self.included(controller)
#       controller.extend(ClassMethods)
#       controller.before_filter(:ensure_proper_protocol)
#     end
#
#     module ClassMethods
#       # Specifies that the named actions requires an SSL connection to be performed (which is enforced by ensure_proper_protocol).
#       def ssl_required(*actions)
#         class_attribute(:ssl_required_actions)
#         self.ssl_required_actions = actions
#       end
#
#       def ssl_allowed(*actions)
#         class_attribute(:ssl_allowed_actions)
#         self.ssl_allowed_actions = actions
#       end
#     end
#
#     protected
#     # Returns true if the current action is supposed to run as SSL
#     def ssl_required?
#       if self.class.respond_to?(:ssl_required_actions)
#         actions = self.class.ssl_required_actions
#         actions.empty? || actions.include?(action_name.to_sym)
#       else
#         return false
#       end
#     end
#
#     def ssl_allowed?
#       if self.class.respond_to?(:ssl_allowed_actions)
#         actions = self.class.ssl_allowed_actions
#         actions.empty? || actions.include?(action_name.to_sym)
#       else
#         return false
#       end
#     end
#
#     private
#
#     def ssl_supported?
#       if Gemgento::Config[:require_ssl] == false
#         return false
#       else
#         return Rails.env.production?
#       end
#     end
#
#     def ensure_proper_protocol
#       return true if ssl_allowed?
#       if ssl_required? && !request.ssl? && ssl_supported?
#         redirect_to "https://" + request.host + request.fullpath
#         flash.keep
#       elsif request.ssl? && !ssl_required?
#         redirect_to "http://" + request.host + request.fullpath
#         flash.keep
#       end
#     end
#   end
# end