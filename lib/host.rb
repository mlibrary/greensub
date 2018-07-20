# frozen_string_literal: true

require 'yaml'

class Host
  attr_accessor :name, :type, :base_uri, :token

  def initialize(name, type)
    @name = name
    @type = type
    data = YAML.load_file('data/hosts.yaml')
    @base_uri = data["#{name}"]["#{type}"]["base_uri"]
    @token = data["#{name}"]["#{type}"]["token"]
  end
end
