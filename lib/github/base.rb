require 'rest-client'
require 'nokogiri'
require 'json'
require 'pry'

class Base
  attr_accessor :id 
  attr_reader :retrieved_object, :retrieved_html

  ALLOWED_ATTRS = [:id]
  API_HOST = 'https://api.github.com/repos/rails/rails'
  HTML_HOST = 'https://github.com/rails/rails'

  def initialize(options = {})
    options.each do |key, value|
      next unless ALLOWED_ATTRS.include?(key)
      instance_variable_set("@#{key}", value)
    end
  end

  def fetch_from_api_source(resource, resource_id = nil)
    url = "#{API_HOST}/#{resource}/#{resource_id}"
    response = RestClient.get url
    @retrieved_object = JSON.parse response.body
  end

  def fetch_from_html_source(resource, resource_id = nil)
    url = "#{HTML_HOST}/#{resource}/#{resource_id}"
    response = RestClient.get url
    @retrieved_html = response
  end  
end
