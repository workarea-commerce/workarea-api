require 'workarea/api/curl'

if ENV['GENERATE_API_DOCS']
  MiniTest.after_run do
    Workarea::Api::DocumentationTest.build_index('admin')
    Workarea::Api::DocumentationTest.build_index('storefront')
  end
end

module Workarea
  module Api
    class DocumentationTest < Workarea::IntegrationTest
      IGNORED_HEADERS = %w(Host Accept)

      class Example
        attr_accessor :resource, :http_method, :route, :description,
          :explanation, :parameters, :response_fields, :requests

        def initialize
          @parameters = []
          @response_fields = []
          @requests = []
        end

        def file_name
          name = @description.presence || "#{@http_method} #{@route}"
          "#{name.systemize}.json"
        end
      end

      class Request
        attr_accessor :request_method, :request_path, :request_body,
                        :request_headers, :request_query_parameters,
                        :request_content_type, :response_status,
                        :response_status_text, :response_body,
                        :response_headers, :response_content_type, :curl

        def initialize
          @request_headers = {}
          @request_query_parameters = {}
          @response_headers = {}
        end
      end

      class << self
        def resource(val = nil)
          @resource = val || @resource
        end

        def docs_root
          @docs_root ||= if running_in_gem?
            Workarea::Api.root.join('doc', 'api')
          else
            Rails.root.join('doc', 'api')
          end
        end

        def running_in_gem?
          Rails.root.to_s.include?('test/dummy')
        end

        def docs_dir
          docs_root.join(engine, resource.systemize)
        end

        def engine
          name.split('::')[-2].downcase
        end

        def build_index(engine)
          results = { 'resources' => [] }
          root = docs_root.join(engine)

          FileUtils.mkdir_p(root)
          begin
            FileUtils.rm(root.join('index.json'))
          rescue
            nil
          end

          Dir.glob(root.join('**/*.json')) do |file|
            example = JSON.parse(File.read(file))

            existing_resource = results['resources'].detect do |resource|
              resource['name'] == example['resource']
            end

            index_example = {
              'description' => example['description'],
              'link' => file.to_s.gsub("#{docs_root}/", ''),
              'groups' => 'all',
              'route' => example['route'],
              'method' => example['http_method']
            }

            if existing_resource.present?
              existing_resource['examples'] << index_example
            else
              results['resources'] << {
                'name' => example['resource'],
                'examples' => [index_example]
              }
            end
          end

          File.open(root.join('index.json'), 'w') do |file|
            file.write(JSON.pretty_generate(results))
          end
        end
      end

      setup :setup_example
      teardown :save_example

      def parameter(name, description)
        @example.parameters << { name: name, description: description }
      end

      def method_missing(method_name, *args, &block)
        if @example.respond_to?("#{method_name}=")
          @example.send("#{method_name}=", *args)
        else
          super
        end
      end

      def respond_to?(method_name, include_private = false)
        @example.respond_to?("#{method_name}=") || super
      end

      def record_request
        yield

        @example.http_method = request.method.upcase if @example.http_method.blank?
        headers = env_to_headers(request.env)
        request_body = read_request_body

        doc_request = Request.new
        doc_request.request_method = request.method
        doc_request.request_path = request.fullpath
        doc_request.request_body = request_body.empty? ? nil : request_body.force_encoding('UTF-8')
        doc_request.request_headers = headers
        doc_request.request_query_parameters = request.query_parameters
        doc_request.request_content_type = headers['Content-Type']
        doc_request.response_status = response.status
        doc_request.response_status_text = response.message
        doc_request.response_body = formatted_response_body
        doc_request.response_headers = filtered_response_headers
        doc_request.response_content_type = response.content_type

        curl = Curl.new(request.method, request.fullpath, request_body, headers)
        doc_request.curl = curl.output("https://#{Workarea.config.host}")

        @example.requests << doc_request
      end

      private

      def setup_example
        @example = Example.new
        @example.resource = self.class.resource
      end

      def save_example
        if passed? && ENV['GENERATE_API_DOCS']
          FileUtils.mkdir_p(self.class.docs_dir)
          File.open(self.class.docs_dir.join(@example.file_name), 'w') do |file|
            file.write(JSON.pretty_generate(JSON.parse(@example.to_json)))
          end
        end
      end

      def read_request_body
        input = request.env['rack.input']
        input.rewind
        input.read
      end

      def formatted_response_body
        return nil if response.body.empty?

        if response.body.encoding == Encoding::ASCII_8BIT
          '[binary data]'
        elsif response.content_type =~ %r{application/json}
          JSON.pretty_generate(JSON.parse(response.body))
        else
          response.body
        end
      end

      def filtered_response_headers
        response.headers.except(*Workarea.config.suppress_api_response_headers)
      end

      def env_to_headers(env)
        headers = {}
        env.each do |key, value|
          if key =~ /^(HTTP_|CONTENT_TYPE)/
            header = key.gsub(/^HTTP_/, '').split('_').map { |s| s.titleize }.join('-')

            if value.present? && !IGNORED_HEADERS.include?(header)
              headers[header] = value
            end
          end
        end
        headers
      end
    end
  end
end
