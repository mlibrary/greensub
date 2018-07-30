# frozen_string_literal: true

require 'yaml'
require 'json'
require_relative 'host'
require_relative 'component'
require 'net/smtp'

class Product
  attr_accessor :id, :external_id, :name, :host, :components
  attr :config

  def initialize(id)
    @id = id
    fetch_data
  end

  def fetch_data
    #encapsulated here to allow for other possibilies later...
    data = YAML.load_file('config/products.yaml')
    @config = data["#{@id}"]
    @external_id = @config["external_id"]
    @name = @config["name"]
    @host = Host.new(@config["host"])
  rescue
      puts "Nothing known about product #{@id}"
      exit
  end

  #Check to see if the host responds to this product
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

  def has_component?(component)
    @host.component_in_product?(component, self)
  end

  def subscriber_can_access?(subscriber)
    @host.subscriber_can_access_product?(subscriber, self)
  end

  def send_instructions(subscriber)
    unless ENV['GREENSUB_NOMAIL'] == '1'
      if subscriber.is_a? Individual
        send_email( subscriber.email,
                    :from => @config['instructions']['from'],
                    :from_alias => @config['instructions']['from_alias'],
                    :subject => @config['instructions']['subject'],
                    :body => @config['instructions']['body'].gsub!('#{subscriber.email}', subscriber.email ) )
      end
    end
  end

  def send_email(to,opts={})
    opts[:server]      ||= 'localhost'
    opts[:from]        ||= 'email@example.com'
    opts[:from_alias]  ||= 'Example Emailer'
    opts[:subject]     ||= "You need to see this"
    opts[:body]        ||= "Important stuff!"

    msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

    begin
      Net::SMTP.start(opts[:server]) do |smtp|
         smtp.send_message msg, opts[:from], to
         #log email sent
      end
    rescue => err
      puts err
    end
  end
end
