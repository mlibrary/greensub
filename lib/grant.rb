# frozen_string_literal: true

require 'date'
require_relative 'product'

class Grant
  attr_accessor :id, :subscriber, :product, :license, :is_new_subscriber

  def initialize(product, subscr, license = nil)
    @subscriber = subscr
    @product = product
    @license = license
    @license = determine_default_license() unless license
  end

  def determine_default_license
    # Default to :full license
    # But we can have some logic here that sets a different default for certain types of products
    # BAR frontlist
    return :full
  end

  def get_license_at_host
    #What does the host say is the license this subscriber holds for this product?

  end

  def create!(force_instructions = false) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    unless @product.host.knows_subscriber?(@subscriber)
      begin
        @product.host.add_subscriber(@subscriber)
        @is_new_subscriber = true
      rescue StandardError => err
        puts "Can't add subscriber #{@subscriber.id} at host #{@product.host.id}:"
        puts err
        # log failure
      end
    end
    if @product.hosted?
      if !@product.subscriber_can_access?(@subscriber)
        success = @product.host.create_grant!(self)
        if success
            @product.send_instructions(@subscriber) if( force_instructions || @is_new_subscriber)
        end
          return success
      end
    else
      puts "Product #{@product.id} not on host #{@product.host.name} (#{@product.host.type})"
      return false
    end
  end

  def expire! # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    return unless @product.host.knows_subscriber?(@subscriber)

    if @product.hosted?
      @product.host.unauthorize(self) if @product.subscriber_can_access?(@subscriber)
    else
      puts "Product #{@product.id} not on host #{@product.host.name} (#{@product.host.type})"
      exit
    end
  end
end
