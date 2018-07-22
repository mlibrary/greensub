# frozen_string_literal: true

require 'yaml'
require_relative 'subscriber'


class Host
  attr_accessor :name, :type, :base_uri, :token, :connection

  def initialize(name)
    @name = name
    @type = ENV['GREENSUB_TEST']=='1' ? :test : :prod
    fetch_data
    make_connection
  end

  def fetch_data
    data = YAML.load_file('data/hosts.yaml')
    @base_uri = data["#{@name}"]["#{@type}"]["base_uri"]
    @token = data["#{@name}"]["#{@type}"]["token"]
  rescue
      abort "Nothing known about host #{@name} (#{@type})"
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
    return false if @connection == nil
    @connection.find_product(identifier: product_id).to_i > 0 ? true : false
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

  def authorize(lease)
    puts "Authorizing #{lease.subscriber.external_id} to #{lease.product.external_id} on #{@name} (#{@type})"
    @connection.link(product_identifier: lease.product.external_id, lessee_identifier: lease.subscriber.external_id ) ? true : false
  end

  def unauthorize(lease)
    puts "De-authorizing #{lease.subscriber.external_id} to #{lease.product.external_id} on #{@name} (#{@type})"
    @connection.unlink(product_identifier: lease.product.external_id, lessee_identifier: lease.subscriber.external_id ) ? true : false
  end
end
