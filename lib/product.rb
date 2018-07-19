# frozen_string_literal: true

require 'yaml'

class Product
  attr_accessor :id, :external_id, :name, :components

  def initialize(id)
    @id = id
    data = YAML.load_file('config/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
  end

end
