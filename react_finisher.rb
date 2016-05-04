require 'erb'

module ReactFinisher
  def call(env)
    @env = env
    finish
  end

  private

  attr_reader :env
  attr_accessor :body

  def props
    @props ||= {}
  end

  def request
    @request ||= Rack::Request.new env
  end

  def status(new_status = nil)
    @status = new_status if new_status
    @status ||= 200
  end

  def headers
    @headers ||= {}
  end

  def redirect?
    status > 300 && status < 400
  end

  def root_component
    @root_component ||= Components::Root.new props unless redirect?
  end

  def body
    return [] if redirect?
    return root_component.body if request.xhr?
    root_component.render
  end

  def content_type
    'text/html'
  end

  def params
    @params ||= env['router.params'] || {}
  end

  def finish
    response_body = body
    response_body = [response_body] unless response_body.is_a?(Array)
    unless redirect?
      headers['Content-Type'] ||= content_type
      headers['X-Page-Title'] ||= root_component.page_title
    end
    [status, headers, response_body]
  end
end
