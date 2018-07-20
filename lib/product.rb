# frozen_string_literal: true

require 'yaml'
require_relative 'host'

class Product
  attr_accessor :id, :external_id, :name, :host, :components

  def initialize(id)
    @id = id
    data = YAML.load_file('data/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
    @host = Host.new(data["#{@id}"]["host"])
  end

  #Check to see if the host responds to this product
  def hosted?
    conn = @host.connection
    conn.get "/api/products/#{@external_id}.json"
  end
end
