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
    data = YAML.safe_load(File.read('config/hosts.yaml'))
    @base_uri = data[@name.to_s][@type.to_s]["base_uri"]
    @token = data[@name.to_s][@type.to_s]["token"]
  rescue StandardError => e
    puts e
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

  def find_component_external_ids_by_identifier(identifier) # rubocop:disable Metrics/MethodLength
    abort "No identifier provided" unless identifier

    # is it an ISBN?
    isbn = Lisbn.new(identifier)

    if isbn.valid?
      @connection.find_noid_by_isbn(isbn: identifier)
    else
      case identifier
      when /doi\.org/, /10.3998/
        @connection.find_noid_by_doi(doi: identifier)
      else
        @connection.find_noid_by_identifier(identifier: identifier)
      end
    end
  rescue StandardError => e
    puts e
  end

  def component_in_product?(component, product)
    @connection.product_component?(product_identifier: product.external_id, component_identifier: component.sales_id)
  rescue StandardError => e
    puts e
  end

  def create_product(product)
    @connection.create_product(identifier: product.external_id, name: product.name, purchase: product.host)
  rescue StandardError => e
    puts e
  end

  def products
    puts "Listing all products on host #{@name} #{@type}"
    @connection.products
  rescue StandardError => e
    puts e
  end

  def knows_product?(product)
    @connection.find_product(identifier: product.external_id)
  rescue StandardError => e
    puts e
    false
  end

  def components
    puts "Listing all components on host #{@name} #{@type}"
    @connection.components
  rescue StandardError => e
    puts e
  end

  def get_components(product)
    @connection.product_components(identifier: product.external_id)
  rescue StandardError => e
    puts e
  end

  def knows_component?(component)
    @connection.find_component_by_noid(noid: component.hosted_id) ? true : false
  rescue StandardError => e
    puts e
    false
  end

  def delete_component(component)
    puts "Deleting #{component.hosted_id} from #{@name} (#{@type})"
    @connection.delete_component(identifier: component.sales_id)
  rescue StandardError => e
    puts e
  end

  def institutions
    puts "Listing all institutions with accounts at host #{@name} #{@type}"
    @connection.institutions
  rescue StandardError => e
    puts e
  end

  def knows_institution?(institution)
    puts "Checking for institution #{institution.external_id} at host #{@name} #{@type}"
    @connection.find_institution(identifier: institution.external_id) ? true : false
  rescue StandardError => e
    puts e
    false
  end

  def add_institution(institution)
    if institution.id && !institution.name.nil?
      @connection.create_institution(identifier: institution.external_id, name: institution.name, entity_id: institution.entity_id)
      @connection.create_institution_affiliation(identifier: institution.external_id, dlps_institution_id: institution.external_id, affiliation: :member)
    else
      abort "Institution name required; use --name"
    end
  rescue StandardError => e
    puts e
  end

  def delete_institution(institution)
    @connection.delete_institution_affiliation(identifier: institution.external_id, dlps_institution_id: institution.external_id, affiliation: :member)
    @connection.delete_institution(identifier: institution.external_id)
  rescue StandardError => e
    puts e
  end

  def get_institutions(product)
    @connection.product_institutions(identifier: product.external_id)
  end

  def individuals
    puts "Listing all individuals with accounts at host #{@name} #{@type}"
    @connection.individuals
  rescue StandardError => e
    puts e
  end

  def knows_individual?(individual)
    @connection.find_individual(identifier: individual.external_id) ? true : false
  rescue StandardError => e
    puts e
    false
  end

  def add_individual(individual)
    if individual.id && !individual.email.nil?
      @connection.create_individual(identifier: individual.external_id, name: "#{individual.lastname}, #{individual.firstname}", email: individual.email)
    else
      abort "Individual email required; use --email"
    end
  rescue StandardError => e
    puts e
  end

  def delete_individual(individual)
    @connection.delete_individual(identifier: individual.external_id)
  rescue StandardError => e
    puts e
  end

  def get_individuals(product)
    @connection.product_individuals(identifier: product.external_id)
  rescue StandardError => e
    puts e
  end

  def get_licenses(product)
    @connection.product_licenses(identifier: product.external_id)
  rescue StandardError => e
    puts e
  end

  def subscribers
    puts "Listing all subscribers with accounts at host #{@name} #{@type}"
    institutions + individuals
  end

  def knows_subscriber?(subscriber)
    case subscriber
    when Institution
      knows_institution?(subscriber)
    when Individual
      knows_individual?(subscriber)
    else
      false
    end
  end

  def add_subscriber(subscriber)
    case subscriber
    when Institution
      add_institution(subscriber) unless knows_institution?(subscriber)
    when Individual
      add_individual(subscriber) unless knows_individual?(subscriber)
    end
  rescue StandardError => e
    puts e
  end

  def delete_subscriber(subscriber)
    case subscriber
    when Institution
      delete_institution(subscriber)
    when Individual
      delete_individual(subscriber)
    end
  rescue StandardError => e
    puts e
  end

  def link(product, component)
    puts "Adding #{component.sales_id} to #{product.external_id} on #{@name} (#{@type})"
    unless knows_component?(component)
      puts "Component not known, creating..."
      connection.create_component(identifier: component.sales_id, name: component.name, noid: component.hosted_id)
    end
    @connection.add_product_component(product_identifier: product.external_id, component_identifier: component.sales_id)
  rescue StandardError => e
    puts e
  end

  def unlink(product, component)
    puts "Removing #{component.sales_id} from #{product.external_id} on #{@name} (#{@type})"
    @connection.remove_product_component(product_identifier: product.external_id, component_identifier: component.sales_id)
  rescue StandardError => e
    puts e
  end

  def get_product_subscriber_license_type(product, subscriber)
    case subscriber
    when Institution
      @connection.find_product_institution_license(identifier: product.external_id, institution_identifier: subscriber.external_id)
    when Individual
      @connection.find_product_individual_license(identifier: product.external_id, individual_identifier: subscriber.external_id)
    end
  rescue StandardError => e
    puts e
  end

  def create_license!(license) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    puts "License #{license.type} access to #{license.product.external_id} for #{license.subscriber.external_id} on #{@name} (#{@type})"
    success = case license.subscriber
              when Institution
                @connection.create_product_institution_license(identifier: license.product.external_id, institution_identifier: license.subscriber.external_id, license_type: license.type)
              when Individual
                @connection.create_product_individual_license(identifier: license.product.external_id, individual_identifier: license.subscriber.external_id, license_type: license.type)
              end
    return true if success

    abort "Could not create license: product_identifier: #{license.product.external_id}, institution_identifier: #{license.subscriber.external_id}, license_type: #{license.type}"
  rescue StandardError => e
    puts e
  end

  def delete_license!(license) # rubocop:disable Metrics/AbcSize
    puts "De-authorizing #{license.subscriber.external_id} to #{license.product.external_id} on #{@name} (#{@type})"
    case license.subscriber
    when Institution
      @connection.delete_product_institution_license(identifier: license.product.external_id, institution_identifier: license.subscriber.external_id)
    when Individual
      @connection.delete_product_individual_license(identifier: license.product.external_id, individual_identifier: license.subscriber.external_id)
    end
  rescue StandardError => e
    puts e
  end
end
