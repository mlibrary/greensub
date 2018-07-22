# frozen_string_literal: true
require_relative 'product'

class Lease
  attr_accessor :id, :subscriber, :product, :starts, :expires

  def initialize(product, subscr)
    @subscriber = subscr
    @product = product
    fetch_data
  end

  def fetch_data
    #see if we have a record of this lease already
    #maybe update other data members
  end

  def authorize #synonym for an immediate, open-ended lease
    if product.hosted?
      #arguably, if a lease exists, we should keep the starts date
        #but since we're logging and not keeping a database, we'll just record
         #each distinct authorization
      @starts = Time.now.strftime('%F') #YYYY-MM-DD
      @expires = nil
      product.host.authorize(self)
      update_data
    else
      puts "Product #{product.id} not on host #{product.host.id} (#{product.host.type})"
      exit
    end
  end

  def expire #synonym for immediate termination of lease (regardless of whether it's active)
    if product.hosted?
      unless @starts == nil
        if Date.parse(@starts) > Time.now.to_date #a lease can't begin after it ends
            @starts = Date.today.strftime('%F')
        end
      end

      @expires = Time.now.strftime('%F') #YYYY-MM-DD
      product.host.unauthorize(self)
      update_data
    else
      puts "Product #{product.id} not on host #{product.host.id} (#{product.host.type})"
      exit
    end
  end

  def update_data
    #just log it for now?
  end

end
