module HealthLetters
  module Actions
    module Root
      class Index
        include ReactFinisher

        def props
          {
            base_component: Components::Home,
            full_title: 'Health Letters: Find NYC restaurant grades near you',
            zip_code: request.params['zipCode']
          }
        end
      end
    end
  end
end
