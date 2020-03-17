# frozen_string_literal: true

require 'date'
require_relative 'product'

class Lease
  attr_accessor :id, :subscriber, :product, :starts, :expires, :action, :is_new_subscriber

  def initialize(product, subscr)
    @subscriber = subscr
    @product = product
    fetch_data
  end

  def fetch_data
    # see if we have a record of this lease already
    # maybe update other data members
  end

  def active?
    today = Time.now.to_date
    if (@expires.is_a?(Date) && @expires < today) || @starts.is_a?(Date) && @starts > today
      false
    else
      true
    end
  end

  def authorize(force_instructions, start = Date.today) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    unless @product.host.knows_subscriber?(@subscriber)
      begin
        @product.host.add_subscriber(@subscriber)
        @is_new_subscriber = true
      rescue StandardError
        puts "Can't add subscriber #{@subscriber.id} at host #{@product.host.id}"
        # log failure
      end
    end
    if @product.hosted?
      # arguably, if a lease exists, we should keep the starts date
      # but since we're logging and not keeping a database, we'll just record
      # each distinct authorization
      @starts = start
      @expires = nil
      if @starts <= Date.today && !@product.subscriber_can_access?(@subscriber)
        @product.host.authorize(self)
        @product.send_instructions(@subscriber) if( force_instructions || @is_new_subscriber)
      end
    else
      puts "Product #{@product.id} not on host #{@product.host.name} (#{@product.host.type})"
      exit
    end
  end

  def expire(expiration_date = Date.today) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    return unless @product.host.knows_subscriber?(@subscriber)

    if @product.hosted?
      unless @starts.nil?
        @starts = Date.today if @starts > Date.today # a lease can't begin after it ends
      end

      @expires = expiration_date
      @product.host.unauthorize(self) if Date.today >= @expires && @product.subscriber_can_access?(@subscriber)
    else
      puts "Product #{@product.id} not on host #{@product.host.name} (#{@product.host.type})"
      exit
    end
  end
end
