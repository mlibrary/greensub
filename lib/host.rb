# frozen_string_literal: true

require 'yaml'
require 'faraday'

class Host
  attr_accessor :name, :type, :base_uri, :token, :connection

  def initialize(name, type='test')
    @name = name
    @type = type
    data = YAML.load_file('data/hosts.yaml')
    @base_uri = data["#{@name}"]["#{@type}"]["base_uri"]
    @token = data["#{@name}"]["#{@type}"]["token"]
    make_connection
  end

  def make_connection
    @connection=Faraday.new(:url => @base_uri) do |conn|
      conn.token_auth(@token)
      conn.adapter Faraday.default_adapter
    end
  end

  def status(path='/')
    res = @connection.get path
    res.status
  end
end
