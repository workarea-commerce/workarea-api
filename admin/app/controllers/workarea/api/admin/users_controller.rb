module Workarea
  module Api
    module Admin
      class UsersController < Admin::ApplicationController
        before_action :find_user, except: [:index, :create, :bulk]

        swagger_path '/users' do
          operation :get do
            key :summary, 'All Users'
            key :description, 'Returns all users from the system'
            key :operationId, 'listUsers'
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
              key :description, 'User'
              schema do
                key :type, :object
                property :user do
                  key :type, :array
                  items do
                    key :'$ref', 'Workarea::User'
                  end
                end
              end
            end
          end

          operation :post do
            key :summary, 'Create User'
            key :description, 'Creates a new user.'
            key :operationId, 'addUser'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'User to add'
              key :required, true
              schema do
                key :type, :object
                property :user do
                  key :'$ref', 'Workarea::User'
                end
              end
            end

            response 201 do
              key :description, 'User created'
              schema do
                key :type, :object
                property :user do
                  key :'$ref', 'Workarea::User'
                end
              end
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::User'
                end
              end
            end
          end
        end


        def index
          @users = User
                      .all
                      .order_by(sort_field => sort_direction)
                      .page(params[:page])

          respond_with users: @users.to_a.map { |u| api_attributes_for(u) }
        end

        def create
          @user = User.create!(params[:user])
          respond_with(
            { user: api_attributes_for(@user) },
            { status: :created,
            location: user_path(@user) }
          )
        end

        swagger_path '/users/{id}' do
          operation :get do
            key :summary, 'Show User by ID'
            key :description, 'Returns a user by ID'
            key :operationId, 'showUser'
            key :produces, ['application/json']

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'user ID'
              key :required, true
              key :type, :string
            end

            response 200 do
              key :description, 'User Details'
              schema do
                key :type, :object
                property :user do
                  key :'$ref', 'Workarea::User'
                end
              end
            end
          end

          operation :patch do
            key :summary, 'Update User'
            key :description, 'Updates attributes on user'
            key :operationId, 'updateUser'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of user to update'
              key :required, true
              key :type, :string
            end

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'New user attributes'
              key :required, true
              schema do
                key :type, :object
                property :user do
                  key :'$ref', 'Workarea::User'
                end
              end
            end

            response 204 do
              key :description, 'User updated successfully'
            end

            response 422 do
              key :description, 'Validation failure'
              schema do
                key :type, :object
                property :problem do
                  key :type, :string
                end
                property :document do
                  key :'$ref', 'Workarea::User'
                end
              end
            end

            response 404 do
              key :description, 'User not found'
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

          operation :delete do
            key :summary, 'Remove a User'
            key :description, 'Remove a User'
            key :operationId, 'removeUser'

            parameter do
              key :name, :id
              key :in, :path
              key :description, 'ID of user to remove'
              key :required, true
              key :type, :string
            end

            response 204 do
              key :description, 'User removed successfully'
            end

            response 404 do
              key :description, 'User not found'
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
          respond_with user: api_attributes_for(@user)
        end

        def update
          @user.update_attributes!(params[:user])
          respond_with user: api_attributes_for(@user)
        end

        def destroy
          @user.destroy
          head :no_content
        end

        swagger_path '/users/bulk' do
          operation :patch do
            key :summary, 'Bulk Upsert Users'
            key :description, 'Creates new users or updates existing ones in bulk.'
            key :operationId, 'upsertUser'
            key :produces, ['application/json']

            parameter do
              key :name, :body
              key :in, :body
              key :description, 'Array of users to upsert'
              key :required, true
              schema do
                key :type, :object
                property :users do
                  items do
                    key :'$ref', 'Workarea::User'
                  end
                end
              end
            end

            response 204 do
              key :description, 'Upsert received'
            end
          end
        end

        def bulk
          @bulk = Api::Admin::BulkUpsert.create!(
            klass: User,
            data: params[:users].map(&:to_h)
          )

          head :no_content
        end

        private

        def find_user
          @user = User.find(params[:id])
        end

        def api_attributes_for(user)
          user.as_json.except('password_digest', 'super_admin', 'name')
        end
      end
    end
  end
end
