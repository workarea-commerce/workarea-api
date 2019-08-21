module Workarea
  module Api
    module Admin
      class EmailSignupsController < Admin::ApplicationController
        swagger_path '/email_signups' do
          operation :get do
            key :summary, 'All Email Signups'
            key :description, 'Returns all email signups from the system'
            key :operationId, 'listEmailSignups'
            key :produces, ['application/json']

            parameter do
              key :name, :page
              key :in, :query
              key :description, 'Current page'
              key :required, false
              key :type, :integer
              key :default, 1
            end
            parameter do
              key :name, :sort_by
              key :in, :query
              key :description, 'Field on which to sort (see responses for possible values)'
              key :required, false
              key :type, :string
              key :default, 'created_at'
            end
            parameter do
              key :name, :sort_direction
              key :in, :query
              key :description, 'Direction for sort by'
              key :type, :string
              key :enum, %w(asc desc)
              key :default, 'desc'
            end

            response 200 do
              key :description, 'Email Signups'
              schema do
                key :type, :object
                property :email_signups do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::Email::Signup'
                  end
                end
              end
            end
          end
        end

        def index
          @email_signups = Email::Signup
                            .all
                            .order_by(sort_field => sort_direction)
                            .page(params[:page])

          respond_with email_signups: @email_signups
        end

        swagger_path '/email_signups/{id}' do
          operation :get do
            key :summary, 'Find Email Signup by ID'
            key :description, 'Returns a single email signup'
            key :operationId, 'showEmailSignup'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of email signup to fetch'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'Email signup details'
              schema do
                key :type, :object
                property :email_signup do
                  key :'$ref', 'Workarea::Email::Signup'
                end
              end
            end

            response 404 do
              key :description, 'Email signup not found'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :params do
                  key :type, :object
                  key :additionalProperties, true
                end
              end
            end
          end
        end

        def show
          @email_signup = Email::Signup.find(params[:id])
          respond_with email_signup: @email_signup
        end
      end
    end
  end
end
