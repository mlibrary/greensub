# frozen_string_literal: true

require 'yaml'

class Product
<<<<<<< eb17d18cc0993c795641a1d97e61bf7bc8eff715
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
=======
  attr_accessor :id, :external_id, :name, :host, :components
>>>>>>> Added Product.host

  def initialize(id)
    @id = id
    data = YAML.load_file('data/products.yaml')
    @external_id = data["#{@id}"]["external_id"]
    @name = data["#{@id}"]["name"]
<<<<<<< eb17d18cc0993c795641a1d97e61bf7bc8eff715
>>>>>>> Basic Product class and tests.
=======
    @host = data["#{@id}"]["host"]
>>>>>>> Added Product.host
  end

end
