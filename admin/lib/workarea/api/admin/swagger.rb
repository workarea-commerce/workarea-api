module Workarea
  module Api
    module Admin
      module Swagger
        extend self

        def models
          @models ||= begin
            result = Mongoid.models.select { |k| k.name.starts_with?('Workarea') }

            result.reject! do |klass|
              Workarea.config.api_admin_ignore_definitions.any? { |d| klass.name =~ d }
            end

            result += result.flat_map(&:subclasses)
            result += [Mongoid::DocumentPath::Node]
            result
          end
        end

        def klasses
          models + Workarea::Api::Admin::ApplicationController.subclasses
        end

        def add_fields(klass, dsl)
          klass.fields.each do |name, metadata|
            next if name == '_type'
            default_value = if metadata.default_val.is_a?(Proc)
              nil
            else
              metadata.default_val
            end

            dsl.property name do
              case metadata.type.to_s
              when 'BSON::ObjectId'
                key :type, :string
              when 'Date'
                key :type, :string
                key :format, :date
                key :default, default_value.as_json if default_value.present?
              when 'Time'
                key :type, :string
                key :format, 'date-time'
                key :default, default_value.as_json if default_value.present?
              when 'Array'
                key :type, :array
                key :default, default_value.to_a if default_value.present?
                items { key :type, :string }
              when 'Hash'
                key :type, :object
                key :additionalProperties, true
                key :default, default_value.to_h if default_value.present?
              when 'Boolean', 'Mongoid::Boolean'
                key :type, :boolean
                key :default, !!default_value if default_value.present?
              when 'Integer'
                key :type, :integer
                key :default, default_value.to_i if default_value.present?
              else
                key :type, :string
                key :default, default_value.to_s if default_value.present?
              end
            end
          end
        end

        def add_relations(klass, dsl)
          klass.relations.values.select(&:embedded?).each do |metadata|
            dsl.property metadata.name do
              if metadata.is_a?(Mongoid::Association::Embedded::EmbedsMany)
                key :type, :array
                items { key :'$ref', metadata.klass.name }
              else
                key :'$ref', metadata.klass.name
              end
            end
          end
        end

        def add_validators(klass, dsl)
          required_attributes = klass
            .validators
            .select { |v| v.is_a?(Mongoid::Validatable::PresenceValidator) }
            .flat_map(&:attributes)
            .select { |a| klass.fields.key?(a) }

          dsl.key :required, required_attributes if required_attributes.any?
        end

        def generate!
          models.each do |klass|
            klass.include(::Swagger::Blocks)
            klass.instance_eval do
              swagger_schema klass.name do
                Swagger.add_validators(klass, self)
                Swagger.add_fields(klass, self)
                Swagger.add_relations(klass, self)
              end
            end
          end
        end
      end
    end
  end
end
