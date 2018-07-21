# frozen_string_literal: true

require 'yaml'


class Host
  attr_accessor :name, :type, :base_uri, :token, :connection

  def initialize(name, type='test')
    @name = name
    @type = type
    data = YAML.load_file('data/hosts.yaml')
    @base_uri = data["#{@name}"]["#{@type}"]["base_uri"]
    @token = data["#{@name}"]["#{@type}"]["token"]
    puts "\nTOKEN = #{@token}\n"
    make_connection
  end

  def make_connection
    if(@name == 'heliotrope')
      require 'turnsole'
      Turnsole::HeliotropeService.default_options[:base_uri] = @base_uri if @base_uri
      Turnsole::HeliotropeService.default_options[:headers][:authorization] = "Bearer #{@token}" if @token
      @connection = Turnsole::HeliotropeService.new
      p @connection
    else
      puts "No connection defined for service #{name}"
      exit!(0)
    end
  end

  def products
    puts "Listing all products on host #{@name} #{@type}"
    @connection.products
  end

  def lessees
    puts "Listing all lessees with accounts at host #{@name} #{@type}"
    @connection.lessees
  end

end
