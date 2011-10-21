require 'logger'

class PivotalHookProxy
  autoload :Forwarding, 'pivotal-hook-proxy/forwarding'
  autoload :RackIntegration, 'pivotal-hook-proxy/rack_integration'


  class << self
    def call(env)
      new(env).process
    end

    def logger
      return @logger if @logger
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      @logger
    end

    def forwardings
      @forwardings ||= {}
    end

    def add_forwarding(project, url)
      forwardings[project.to_sym] ||= []
      forwardings[project.to_sym] << Forwarding.new(url)
    end

    def forwardings_for(project)
      return nil if project.nil? or project.length == 0
      forwardings[project.to_sym]
    end

    def reset_forwardings!
      @forwardings = nil
    end
  end

  attr_reader :env, :request
  private :env, :request

  def initialize(env)
    @env = env
    @request = Rack::Request.new(env)
    PivotalHookProxy.logger.info "#{request.request_method} #{request.fullpath}"
  end

  def process
    if activity_hook_triggered?
      PivotalHookProxy.logger.info "Activity Hook triggered for #{requested_project_name} with:\n#{post_body}"
      forwardings.each {|forwarding| forwarding.forward post_body }
      return [201, {"Content-Type" => 'application/xml'}, [post_body]]

    elsif request.get? and request.path == '/'
      return [200, {"Content-Type" => 'text/plain'}, ['Hello.']]
    else
      PivotalHookProxy.logger.info "Could not find #{request.request_method} #{request.fullpath}"
      return [404, {"Content-Type" => 'text/plain'}, ['Resource not found']]
    end
  rescue => err
    PivotalHookProxy.logger.warn "#{request.request_method} #{request.fullpath} caused an exception: #{err}\n#{err.backtrace}"
    return [500, {"Content-Type" => 'text/plain'}, ['Something went wrong :(']]
  end

  def activity_hook_triggered?
    request.post? and not forwardings.nil?
  end

  def post_body
    @post_body ||= request.body.read
  end

  def requested_project_name
    path_parts = request.path.split('/').reject {|part| part.strip.length == 0 }
    if path_parts.count == 2 and path_parts.first == 'activity'
      path_parts[1]
    end
  end

  def forwardings
    @forwardings ||= PivotalHookProxy.forwardings_for(requested_project_name)
  end
end

# Rack config.ru shorthand
Rack::Builder.send :include, PivotalHookProxy::RackIntegration if defined?(Rack::Builder)