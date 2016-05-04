module HealthLetters
  module Actions
    module Results
      class Create
        include ReactFinisher

        def call(env)
          @env = env
          status 301
          headers['Location'] = destination_path(request.params)
          finish
        end

        private

        def destination_path(params)
          latitude = params['latitude']
          longitude = params['longitude']
          "/results/#{[latitude, longitude].join ','}"
        end
      end
    end
  end
end
