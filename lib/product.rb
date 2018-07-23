# frozen_string_literal: true

require 'yaml'
require 'json'
require_relative 'host'


class Product
  attr_accessor :id, :external_id, :name, :host, :components

  def initialize(id)
    @id = id
    fetch_data
  end

  def fetch_data
    #encapsulated here to allow for other possibilies later...
    data = YAML.load_file('data/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
    @host = Host.new(data["#{@id}"]["host"])
  rescue
      puts "Nothing known about product #{@id}"
      exit
  end

  #Check to see if the host responds to this product
  def hosted?
    @host.hosted?(@external_id) ? true : false
  end
end
