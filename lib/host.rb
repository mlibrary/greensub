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
    data = YAML.load_file('config/hosts.yaml')
    @base_uri = data["#{@name}"]["#{@type}"]["base_uri"]
    @token = data["#{@name}"]["#{@type}"]["token"]
  rescue
      abort "Nothing known about host #{@name} (#{@type})"
  end

  def make_connection
    if(@name == 'heliotrope')
      require 'turnsole/heliotrope/service'
      @connection = Turnsole::Heliotrope::Service.new(base: @base_uri, token: @token)
    else
      @connection = nil
    end
  end

  def hosted?(product_id)
    abort "No connection for #{product_id}" if @connection == nil
    @connection.find_product(identifier: product_id).to_i > 0 ? true : false
  end

  def component_in_product?(component, product)
    @connection.product_component?(product_identifier: product.external_id, component_identifier: component.hosted_id)
  end

  def subscriber_can_access_product?(subscriber, product)
    if subscriber.is_a?(Institution)
      @connection.product_institution_subscribed?(product_identifier: product.external_id, institution_identifier: subscriber.external_id)
    elsif subscriber.is_a?(Individual)
      @connection.product_individual_subscribed?(product_identifier: product.external_id, individual_identifier: subscriber.external_id)
    else
      false
    end
  end

  def create_product(product)
    @connection.create_product(identifier: product.external_id, name: product.name, purchase: product.host)
  end

  def products
    puts "Listing all products on host #{@name} #{@type}"
    @connection.products
  end

  def knows_product?(product)
    @connection.find_product(identifier: product.external_id)
  end

  def components
    puts "Listing all components on host #{@name} #{@type}"
    @connection.components
  end

  def knows_component?(component)
    @connection.find_component(identifier: component.hosted_id)
  end

  def institutions
    puts "Listing all institutions with accounts at host #{@name} #{@type}"
    @connection.institutions
  end

  def knows_institution?(institution)
    @connection.find_institution(identifier: institution.external_id) ? true : false
  end

  def add_institution(institution)
    if ( institution.id && institution.name != nil )
      @connection.create_institution(identifier: institution.external_id, name: institution.name, entity_id: institution.entity_id)
    else
      abort "Institution name required; use --name"
    end
  rescue => err
    puts err
  end

  def delete_institution(institution)
    @connection.delete_institution(identifier: institution.external_id)
  rescue => err
    puts err
  end

  def individuals
    puts "Listing all individuals with accounts at host #{@name} #{@type}"
    @connection.individuals
  end

  def knows_individual?(individual)
    @connection.find_individual(identifier: individual.external_id) ? true : false
  end

  def add_individual(individual)
    if ( individual.id && individual.email != nil )
      @connection.create_individual(identifier: individual.external_id, name: "#{individual.lastname}, #{individual.firstname}", email: individual.email)
    else
      abort "Individual email required; use --email"
    end
  rescue => err
    puts err
  end

  def delete_individual(individual)
    @connection.delete_individual(identifier: individual.external_id)
  rescue => err
    puts err
  end

  def subscribers
    puts "Listing all subscribers with accounts at host #{@name} #{@type}"
    institutions + individuals
  end

  def knows_subscriber?(subscriber)
    if subscriber.is_a?(Institution)
      knows_institution?(subscriber)
    elsif subscriber.is_a?(Individual)
      knows_individual?(subscriber)
    else
      false
    end
  end

  def add_subscriber(subscriber)
    if subscriber.is_a?(Institution)
      add_institution(subscriber) unless knows_institution?(subscriber)
    elsif subscriber.is_a?(Individual)
      add_individual(subscriber) unless knows_individual?(subscriber)
    end
  rescue => err
    puts err
  end

  def delete_subscriber(subscriber)
    if subscriber.is_a?(Institution)
      delete_institution(subscriber)
    elsif subscriber.is_a?(Individual)
      delete_individual(subscriber)
    end
  rescue => err
    puts err
  end

  def authorize(lease)
    puts "Authorizing #{lease.subscriber.external_id} to #{lease.product.external_id} on #{@name} (#{@type})"
    if lease.subscriber.is_a?(Institution)
      @connection.subscribe_product_institution(product_identifier: lease.product.external_id, institution_identifier: lease.subscriber.external_id)
    elsif lease.subscriber.is_a?(Individual)
      @connection.subscribe_product_individual(product_identifier: lease.product.external_id, individual_identifier: lease.subscriber.external_id)
    end
  rescue => err
      puts err
  end

  def unauthorize(lease)
    puts "De-authorizing #{lease.subscriber.external_id} to #{lease.product.external_id} on #{@name} (#{@type})"
    if lease.subscriber.is_a?(Institution)
      @connection.unsubscribe_product_institution(product_identifier: lease.product.external_id, institution_identifier: lease.subscriber.external_id)
    elsif lease.subscriber.is_a?(Individual)
      @connection.unsubscribe_product_individual(product_identifier: lease.product.external_id, individual_identifier: lease.subscriber.external_id)
    end
  rescue => err
    puts err
  end

  def link(product, component)
    puts "Adding #{component.hosted_id} to #{product.external_id} on #{@name} (#{@type})"
    @connection.add_product_component(product_identifier: product.external_id, component_identifier: component.hosted_id)
  rescue => err
    puts err
  end

  def unlink(product, component)
    puts "Removing #{component.hosted_id} from #{product.external_id} on #{@name} (#{@type})"
    @connection.remove_product_component(product_identifier: product.external_id, component_identifier: component.hosted_id)
  rescue => err
    puts err
  end
end
