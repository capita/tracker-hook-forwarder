require 'httparty'
require 'uri'

class PivotalHookProxy
  class Forwarding
    attr_reader :url
    include HTTParty

    def initialize(url)
      @url = url.freeze
      unless [URI::HTTP, URI::HTTPS].include? URI.parse(url).class
        raise ArgumentError, "Forwarding url must be either http or https!"
      end
    end

    def forward(body)
      response = Forwarding.post(url, :body => body).response
      if response.kind_of?(Net::HTTPSuccess)
        PivotalHookProxy.logger.info "Forwarded to #{url}:\n#{body}"
        true
      else 
        PivotalHookProxy.logger.warn "Forwarding to #{url} failed with #{response.class}:\n#{body}"
        false
      end
    rescue => err
      PivotalHookProxy.logger.error "Forwarding to #{url} caused an error #{err}:\n#{body}"
      false
    end
  end
end