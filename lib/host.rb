# frozen_string_literal: true

require 'yaml'
require 'lisbn'
require_relative 'subscriber'

class Host # rubocop:disable Metrics/ClassLength
  attr_accessor :name, :type, :base_uri, :token, :connection

  def initialize(name)
    @name = name
    @type = ENV['GREENSUB_TEST'] == '1' ? :test : :prod
    fetch_data
    make_connection
  end

  def fetch_data
    data = YAML.load_file('config/hosts.yaml')
    @base_uri = data[@name.to_s][@type.to_s]["base_uri"]
    @token = data[@name.to_s][@type.to_s]["token"]
  rescue StandardError => err
    puts err
    abort "Failed to find host #{@name} (#{@type})"
  end

  def make_connection
    if @name == 'heliotrope'
      require 'turnsole/heliotrope/service'
      @connection = Turnsole::Heliotrope::Service.new(base: @base_uri, token: @token)
    else
      @connection = nil
    end
  end

  def hosted?(product_id)
    abort "No connection for #{product_id}" if @connection.nil?
    @connection.find_product(identifier: product_id).to_i.positive?
  end

  def find_component_external_id_by_identifier(identifier)

    return false unless identifier

    #is it an ISBN?
    isbn = Lisbn.new(identifier)
    results = ''

    if isbn.valid?
      results = @connection.find_noid_by_isbn(isbn: identifier)
    else
      case identifier
      when /doi\.org/
        results = @connection.find_noid_by_doi(doi: identifier)
      when /10.3998/
        results = @connection.find_noid_by_doi(doi: identifier)
      else
        results = @connection.find_noid_by_identifier(identifier: identifier)
      end
    end
    return results[0]['id']

  rescue StandardError => err
    puts err
  end

  def component_in_product?(component, product)
    @connection.product_component?(product_identifier: product.external_id, component_identifier: component.sales_id)
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

  def get_components(product)
    @connection.product_components(identifier: product.external_id)
  end

  def knows_component?(component)
    @connection.find_component_by_noid(noid: component.hosted_id) ? true : false
  end

  def delete_component(component)
    puts "Deleting #{component.sales_id} from #{@name} (#{@type})"
    @connection.delete_component(identifier: component.sales_id)
  rescue StandardError => err
    puts err
  end

  def institutions
    puts "Listing all institutions with accounts at host #{@name} #{@type}"
    @connection.institutions
  end

  def knows_institution?(institution)
    @connection.find_institution(identifier: institution.external_id) ? true : false
  end

  def add_institution(institution)
    if institution.id && !institution.name.nil?
      @connection.create_institution(identifier: institution.external_id, name: institution.name, entity_id: institution.entity_id)
    else
      abort "Institution name required; use --name"
    end
  rescue StandardError => err
    puts err
  end

  def delete_institution(institution)
    @connection.delete_institution(identifier: institution.external_id)
  rescue StandardError => err
    puts err
  end

  def get_institutions(product)
    @connection.product_institutions(identifier: product.external_id)
  end

  def individuals
    puts "Listing all individuals with accounts at host #{@name} #{@type}"
    @connection.individuals
  end

  def knows_individual?(individual)
    @connection.find_individual(identifier: individual.external_id) ? true : false
  end

  def add_individual(individual)
    if individual.id && !individual.email.nil?
      @connection.create_individual(identifier: individual.external_id, name: "#{individual.lastname}, #{individual.firstname}", email: individual.email)
    else
      abort "Individual email required; use --email"
    end
  rescue StandardError => err
    puts err
  end

  def delete_individual(individual)
    @connection.delete_individual(identifier: individual.external_id)
  rescue StandardError => err
    puts err
  end

  def get_individuals(product)
    @connection.product_individuals(identifier: product.external_id)
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
  rescue StandardError => err
    puts err
  end

  def delete_subscriber(subscriber)
    if subscriber.is_a?(Institution)
      delete_institution(subscriber)
    elsif subscriber.is_a?(Individual)
      delete_individual(subscriber)
    end
  rescue StandardError => err
    puts err
  end

  def create_grant!(grant) # rubocop:disable Metrics/AbcSize
    puts "Granting #{grant.license} access to #{grant.product.external_id} for #{grant.subscriber.external_id} on #{@name} (#{@type})"
    if grant.subscriber.is_a?(Institution)
      success = @connection.set_product_institution_license(product_identifier: grant.product.external_id, institution_identifier: grant.subscriber.external_id, license: grant.license)
    elsif grant.subscriber.is_a?(Individual)
      success = @connection.set_product_individual_license(product_identifier: grant.product.external_id, individual_identifier: grant.subscriber.external_id, license: grant.license)
    else
      abort "Unknown subscriber type"
      false
    end
    if ! success
      abort "Could not create grant: product_identifier: #{grant.product.external_id}, institution_identifier: #{grant.subscriber.external_id}, license: #{grant.license}"
    end
    return success
  rescue StandardError => err
    puts err
  end

  def expire_grant!(grant) # rubocop:disable Metrics/AbcSize
    puts "De-authorizing #{grant.subscriber.external_id} to #{grant.product.external_id} on #{@name} (#{@type})"
    if grant.subscriber.is_a?(Institution)
      @connection.set_product_institution_license(product_identifier: grant.product.external_id, institution_identifier: grant.subscriber.external_id, license: :none)
    elsif grant.subscriber.is_a?(Individual)
      @connection.set_product_individual_license(product_identifier: grant.product.external_id, individual_identifier: grant.subscriber.external_id, license: :none)
    end
  rescue StandardError => err
    puts err
  end

  def get_product_subscriber_license(product, subscriber)
    if subscriber.is_a?(Institution)
      @connection.get_product_institution_license(product_identifier: product.external_id, institution_identifier: subscriber.external_id)
    elsif subscriber.is_a?(Individual)
      @connection.get_product_individual_license(product_identifier: product.external_id, individual_identifier: subscriber.external_id)
    end

  end

  def link(product, component) # rubocop:disable Metrics/AbcSize
    puts "Adding #{component.sales_id} to #{product.external_id} on #{@name} (#{@type})"
    unless knows_component?(component)
      puts "Component not known, creating..."
      connection.create_component(identifier: component.sales_id, name: component.name, noid: component.hosted_id)
    end
    @connection.add_product_component(product_identifier: product.external_id, component_identifier: component.sales_id)
  rescue StandardError => err
    puts err
  end

  def unlink(product, component)
    puts "Removing #{component.sales_id} from #{product.external_id} on #{@name} (#{@type})"
    @connection.remove_product_component(product_identifier: product.external_id, component_identifier: component.sales_id)
  rescue StandardError => err
    puts err
  end
end
