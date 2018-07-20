# frozen_string_literal: true

require 'yaml'

class Product
  attr_accessor :id, :external_id, :name, :host, :components

  def initialize(id)
    @id = id
    data = YAML.load_file('data/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
    @host = data["#{@id}"]["host"]
  end

end
