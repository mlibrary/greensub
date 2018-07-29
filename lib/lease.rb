# frozen_string_literal: true
require_relative 'product'

class Lease
  attr_accessor :id, :subscriber, :product, :starts, :expires, :action, :is_new_subscriber

  def initialize(product, subscr)
    @subscriber = subscr
    @product = product
    fetch_data
  end

  def fetch_data
    #see if we have a record of this lease already
    #maybe update other data members
  end

  def active?
    today = Time.now.to_date
    if ( @expires.is_a?(Date) && @expires < today ) || @starts.is_a?(Date) && @starts > today
      false
    else
      true
    end
  end

  def authorize(start=Date.today)
    if ! @product.host.knows_subscriber?(@subscriber)
      begin
        @product.host.add_subscriber(@subscriber)
        @is_new_subscriber = true
      rescue
        puts "Can't add subscriber #{@subscriber.id} at host #{@product.host.id}"
        #log failure
      end
    end
    if @product.hosted?
      #arguably, if a lease exists, we should keep the starts date
        #but since we're logging and not keeping a database, we'll just record
         #each distinct authorization
      @starts = start
      @expires = nil
      if @starts <= Date.today
        @product.host.authorize(self)
        if @product.subscriber_can_access?(@subscriber)
          #log success
          @product.send_instructions(@subscriber) if @is_new_subscriber
        else
          #log failure
        end
      end
    else
      puts "Product #{@product.id} not on host #{@product.host.id} (#{@product.host.type})"
      exit
    end
  end

  def expire(expiration_date=Date.today)
    if ! @product.host.knows_subscriber?(@subscriber)
      puts "Subscriber #{@subscriber.id} is not on host #{@product.host.name}, so nothing to expire"
    else
      if @product.hosted?
        unless @starts == nil
          if @starts > Date.today #a lease can't begin after it ends
              @starts = Date.today
          end
        end

        @expires = expiration_date
        if Date.today >= @expires
            @product.host.unauthorize(self)
        end
      else
        puts "Product #{@product.id} not on host #{@product.host.id} (#{@product.host.type})"
        exit
      end
    end
  end
end
