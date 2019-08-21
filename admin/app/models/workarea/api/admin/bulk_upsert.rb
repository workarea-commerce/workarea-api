module Workarea
  module Api
    module Admin
      class BulkUpsert
        include ApplicationDocument

        field :klass, type: String
        field :data, type: Array, default: []
        field :data_errors, type: Hash, default: {}
        field :started_at, type: DateTime
        field :completed_at, type: DateTime

        validates :data,
          presence: true,
          length: {
            maximum: Workarea.config.max_api_bulk_data_size,
            message: I18n.t('workarea.api.admin.bulk_upserts.data_too_large')
          }

        validate :model_validity

        def perform!
          update_attribute(:started_at, Time.now)

          data.each_with_index do |attrs, i|
            instance = find_updated_model_for(attrs)
            instance.save

            if instance.errors.present?
              data_errors[i.to_s] = instance.errors.as_json
            end
          end

          if data_errors.blank?
            destroy!
          else
            self.completed_at = Time.now
            save!(validate: false)
          end
        end

        def model_class
          @model_class ||= klass.constantize
        end

        private

        def model_validity
          data.each_with_index do |attrs, i|
            instance = find_updated_model_for(attrs)

            next if instance.valid?
            instance.errors.full_messages.each do |message|
              errors.add(i.to_s, message)
            end
          end
        end

        def find_updated_model_for(attrs)
          id = attrs['_id'].presence || attrs['id'].presence ||
                 attrs[:_id].presence || attrs[:id]

          if id.present?
            result = model_class.find_or_initialize_by(id: id)
            result.attributes = attrs
            result
          else
            model_class.new(attrs)
          end
        end
      end
    end
  end
end
