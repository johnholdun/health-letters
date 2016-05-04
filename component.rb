require 'tilt'

class Component
  def initialize(props = {})
    @props = props
  end

  def render
    self.class.template.render self
  end

  class << self
    def render(props = {})
      new(props).render
    end

    def template(filename = nil)
      return @template if filename.nil?
      @template = Tilt.new filename
    end
  end

  private

  attr_reader :props
end
