module HealthLetters
  module Actions
    module Results
      class Index
        include ReactFinisher

        def props
          @props ||=
            {
              base_component: Components::Results,
              title: neighborhood,
              results: results
            }
        end

        private

        def latitude
          params[:latitude].to_f
        end

        def longitude
          params[:longitude].to_f
        end

        def results
          @results ||=
            RESULTS
            .select { |r| %i(latitude longitude).all? { |k| r[k].present? } }
            .sort_by { |r| (r[:latitude] - latitude) ** 2 + (r[:longitude] - longitude) ** 2 }
            .take 20
        end

        def neighborhood
          @neighborhood ||=
            results.map { |r| r[:neighborhood] }.select(&:present?).first
        end
      end
    end
  end
end
