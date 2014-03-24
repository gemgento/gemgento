if defined?(ActiveAdmin)
  module Gemgento
    ActiveAdmin.register ApiJob do
      menu priority: 100, parent: 'Gemgento', label: 'API Jobs'

      actions :all, :only => [:index, :show ]

      index do
        column :source_type
        column 'source_id' do |api_job|
          if api_job.source_type == 'Gemgento::Order'
            api_job.source.increment_id
          else
            api_job.source_id
          end
        end
        column :state
        column :type
        column :response_status
        column :created_at
        column :updated_at

        actions :defaults => false do |job|
          link_to 'Show', admin_gemgento_api_job_path(job)
        end
      end

      controller do
        def permitted_params
          params.permit(
              :gemgento_store => [
                  :currency_code
              ])
        end
      end

    end
  end
end