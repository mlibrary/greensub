# frozen_string_literal: true

require 'date'
require 'turnsole'
require_relative 'product'
require_relative 'subscriber'

LICENSE_TYPES = %i[full read].freeze
AFFILIATION_TYPES = %i[member alum walk_in].freeze

class License
  attr_accessor :id, :product, :subscriber, :type, :is_new_subscriber

  def initialize(product, subscr, type: nil)
    @subscriber = subscr
    @product = product
    @type = type || determine_default_type
    @is_new_subscriber = false
  end

  def determine_default_type
    # Default to :full
    # But we can have some logic here that sets a different default for certain types of products
    # e.g. BAR frontlist
    :full
  end

  def create!(force_instructions = false) # rubocop:disable Style/OptionalBooleanParameter, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/AbcSize
    return false unless product_hosted?

    unless @product.host.knows_subscriber?(@subscriber)
      begin
        if @product.host.add_subscriber(@subscriber)
          @is_new_subscriber = true
        else
          puts "Add subscriber #{@subscriber.id} failed at host #{@product.host.id}"
          return false
        end
      rescue StandardError => e
        puts "Add subscriber #{@subscriber.id} failed at host #{@product.host.id} with error: #{e}"
        return false
      end
    end

    return false unless @product.host.create_license!(self)

    @product.send_instructions(@subscriber) if force_instructions || @is_new_subscriber
    true
  end

  def delete!
    return false unless product_hosted?
    return false unless @product.host.knows_subscriber?(@subscriber)

    @product.host.delete_license!(self)
  end

  private

    def product_hosted?
      return true if @product.hosted?

      puts "Product #{@product.id} not on host #{@product.host.name} (#{@product.host.type})"
      false
    end
end
