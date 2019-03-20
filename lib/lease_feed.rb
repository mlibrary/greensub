# frozen_string_literal: true

require 'date'
require 'typhoeus'
require 'nokogiri'
require_relative 'lease'
require_relative 'subscriber'

class LeaseFeed
  attr_accessor :datastream, :product

  def initialize(prod)
    @product = prod
  end
end

class HEBLeaseFeed < LeaseFeed
  # move to parent class and use config?
  def fetch # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    config = YAML.load_file('config/lease_feeds.yaml')
    url = config['heb']['source']
    username = config['heb']['username']
    password = config['heb']['password']
    request = Typhoeus::Request.new(url, userpwd: "#{username}:#{password}")

    request.on_complete do |response|
      if response.success?
        # nothing
      elsif response.timed_out?
        # log("got a time out")
      elsif response.code.zero?
        # log(response.return_message)
      end
    end

    request.run
    response = request.response
    @datastream = Nokogiri::XML(response.body)
  end

  # knows how to create the subscriber and determine the action
  def parse # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    xml = @datastream
    feed_records = xml.xpath('/ACLSExport/acls')
    feed_records.each do |fr|
      subscriber = Individual.new(fr.xpath('email').text)
      subscriber.lastname = fr.xpath('lastname').text
      subscriber.firstname = fr.xpath('firstname').text
      subscriber.phone = fr.xpath('phone').text

      lease = Lease.new(@product, subscriber)
      fr.xpath('expirationdate').text
      exp = fr.xpath('expirationdate').text.split('-')
      next unless Date.valid_date?(exp[0].to_i, exp[1].to_i, exp[2].to_i)

      expiration_date = Date.parse(fr.xpath('expirationdate').text)
      lease.authorize if Date.today < expiration_date
      lease.expire(expiration_date)
    end
  end
end

class TestLeaseFeed < HEBLeaseFeed
  def fetch
    config = YAML.load_file('config/lease_feeds.yaml')
    xml = config['test']['xml']
    @datastream = Nokogiri::XML(xml)
  end
end
