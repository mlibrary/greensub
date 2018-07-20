# frozen_string_literal: true

require 'yaml'

class Product
<<<<<<< 4b7b754eedd9eb31bf377e00adbd5f7b4eb4b951
  attr_accessor :id, :external_id, :name, :host, :components

  def initialize(id)
    @id = id
    data = YAML.load_file('data/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
    @host = data["#{@id}"]["host"]
=======
  attr_accessor :id, :external_id, :name, :components

  def initialize(id)
    @id = id
    data = YAML.load_file('data/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
>>>>>>> Basic Product class and tests.
  end

end
