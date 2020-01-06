# frozen_string_literal: true

require 'yaml'
require 'json'
require_relative 'host'
require_relative 'component'
require 'net/smtp'

class Product
  attr_accessor :id, :external_id, :name, :host, :components
  attr_reader :config

  def initialize(id)
    @id = id
    fetch_data
  end

  def fetch_data
    # encapsulated here to allow for other possibilies later...
    data = YAML.load_file('config/products.yaml')
    @config = data[@id.to_s]
    @external_id = @config["external_id"]
    @name = @config["name"]
    @host = Host.new(@config["host"])
  rescue StandardError
    puts "Nothing known about product #{@id}"
    exit
  end

  # Check to see if the host responds to this product
  def hosted?
    @host.hosted?(@external_id) ? true : false
  end

  def create
    @host.create_product(self)
  end

  def delete
    @host.delete_product(self)
  end

  def add(component)
    @host.link(self, component)
  end

  def remove(component)
    @host.unlink(self, component)
  end

  def has_component?(component) # rubocop:disable Naming/PredicateName
    @host.component_in_product?(component, self)
  end

  def list_components
    @host.get_components(self)
  end

  def list_institutions
    @host.get_institutions(self)
  end

  def subscriber_can_access?(subscriber)
    @host.subscriber_can_access_product?(subscriber, self)
  end

  def send_instructions(subscriber) # rubocop:disable Metrics/AbcSize
    return if ENV['GREENSUB_NOMAIL'] == '1'

    return unless subscriber.is_a? Individual

    send_email(subscriber.email,
               from: @config['instructions']['from'],
               from_alias: @config['instructions']['from_alias'],
               bcc: @config['instructions']['bcc'],
               subject: @config['instructions']['subject'],
               body: @config['instructions']['body'].gsub("'#{subscriber.email}'", subscriber.email))
  end

  def send_email(to, opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    opts[:server]      ||= 'localhost'
    opts[:from]        ||= 'email@example.com'
    opts[:from_alias]  ||= 'Example Emailer'
    opts[:subject]     ||= "You need to see this"
    opts[:body]        ||= "Important stuff!"

    msg = <<~END_OF_MESSAGE
      From: #{opts[:from_alias]} <#{opts[:from]}>
      To: <#{to}>
      Subject: #{opts[:subject]}

      #{opts[:body]}
    END_OF_MESSAGE

    begin
      Net::SMTP.start(opts[:server]) do |smtp|
        smtp.send_message msg, opts[:from], to, opts[:bcc]
      end
      puts "Sent email to #{to}"
    rescue StandardError => err
      puts err
    end
  end
end
