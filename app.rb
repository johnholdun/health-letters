require './react_finisher'
require './component'

Dir.glob(File.expand_path('../actions/**/*.rb', __FILE__)).each do |f|
  require f
end

Dir.glob(File.expand_path('../components/**/*.rb', __FILE__)).each do |f|
  require f
end

module HealthLetters
  class App
    ROUTES = [
      {
        method: 'GET',
        path: %r(\A/results/(-?[0-9]+\.[0-9]+),(-?[0-9]+\.[0-9]+)\Z),
        captures: %i(latitude longitude),
        class: HealthLetters::Actions::Results::Index
      },
      {
        method: 'POST',
        path: %r(\A/search\Z),
        class: HealthLetters::Actions::Results::Create
      },
      {
        method: 'GET',
        path: %r(\A/\Z),
        class: HealthLetters::Actions::Root::Index
      }
    ].freeze

    ::RESULTS = JSON.parse(File.read('places.json'), symbolize_names: true)

    def call(env)
      @env = env
      @uri = URI request.url
      return asset_response if asset_path?
      route!
    end

    private

    attr_accessor \
      :env,
      :request,
      :status_code,
      :headers,
      :body,
      :method,
      :uri

    def request
      @request ||= Rack::Request.new env
    end

    def route!
      route =
        ROUTES.find do |r|
          r[:method] == request.request_method && r[:path] =~ uri.path
        end

      raise "No route found for #{request.request_method} #{uri.path}" unless route

      params =
        if route[:captures].is_a?(Array)
          Hash[route[:captures].zip Regexp.last_match.to_a[1..-1]]
        else
          {}
        end

      route[:class].new.call env.merge('router.params' => params)
    end

    def asset_path
      "public#{uri.path}"
    end

    def asset_path?
      File.exist?(asset_path) && !Dir.exist?(asset_path)
    end

    def asset_response
      [
        200,
        {
          'Content-Type' => Rack::Mime::MIME_TYPES[File.extname(asset_path)]
        },
        [File.read(asset_path)]
      ]
    end
  end
end
