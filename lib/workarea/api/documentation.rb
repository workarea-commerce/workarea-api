module Workarea
  module Api
    class Documentation < Raddocs::App
      set :views, Workarea::Api.root.join(
        'app',
        'views',
        'workarea',
        'api',
        'docs'
      )

      helpers do
        def index_path
          if request.path_info.starts_with?('/admin')
            '/admin'
          elsif request.path_info.starts_with?('/storefront')
            '/storefront'
          else
            '/'
          end
        end

        def markdown
          Redcarpet::Markdown.new(
            Redcarpet::Render::HTML,
            autolink: true,
            fenced_code_blocks: true,
            no_intra_emphasis: true
          )
        end
      end

      get '/' do
        content = File.read("#{Workarea::Api::Engine.root}/README.md")
        haml :index, layout: false, locals: { content: content }
      end

      get '/admin' do
        index = Raddocs::Index.new(File.join(docs_dir, 'admin', 'index.json'))
        content = File.read("#{Workarea::Api::Admin::Engine.root}/README.md")
        haml :engine_index, locals: { index: index, content: content }
      end

      get '/storefront' do
        index = Raddocs::Index.new(File.join(docs_dir, 'storefront', 'index.json'))
        content = File.read("#{Workarea::Api::Storefront::Engine.root}/README.md")
        haml :engine_index, locals: { index: index, content: content }
      end

      get '/*' do
        file = File.join(docs_dir, "#{params[:splat][0]}.json")
        raise Sinatra::NotFound unless File.exists?(file)

        index = Raddocs::Index.new(File.join(docs_dir, index_path, 'index.json'))
        example = Raddocs::Example.new(file)

        haml :example, locals: { index: index, example: example }
      end
    end
  end
end
