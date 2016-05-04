module Components
  class Root < Component
    template 'templates/root.html.erb'

    def page_title
      return props[:full_title] if props[:full_title].present?
      title = 'Health Letters'
      title = "#{props[:title]} - #{title}" if props[:title].present?
      title
    end

    def body
      props[:base_component].render props
    end
  end
end
