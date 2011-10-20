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
      if Forwarding.post(url, :body => body).response.kind_of?(Net::HTTPSuccess)
        true
      else 
        false
      end
    rescue => err
      false
    end
  end
end