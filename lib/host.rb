# frozen_string_literal: true

require 'yaml'
require_relative 'subscriber'


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
    if(@name == 'heliotrope')
      require 'turnsole'
      Turnsole::HeliotropeService.default_options[:base_uri] = @base_uri if @base_uri
      Turnsole::HeliotropeService.default_options[:headers][:authorization] = "Bearer #{@token}" if @token
      @connection = Turnsole::HeliotropeService.new
    else
      @connection = nil
    end
  end

  def hosted?(product_id)
    @connection.find_product(identifier: product_id) > 0 ? true : false
  end

  def products
    puts "Listing all products on host #{@name} #{@type}"
    puts @connection.products
  end

  def lessees
    puts "Listing all lessees with accounts at host #{@name} #{@type}"
    puts @connection.lessees
  end

  def knows_subscriber(subscriber)
    @connection.find_lessee(identifier: subscriber.external_id) ? true : false
  end

  def add_subscriber(subscriber)
    @connection.create_lessee(identifier: subscriber.external_id) ? true : false
  rescue => err
    puts err
  end
end
