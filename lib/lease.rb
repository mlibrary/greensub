# frozen_string_literal: true

class Lease
  attr_accessor :id, :subscriber_id, :product_id, :starts, :expires

  def initialize(subscr, product)
    @subscriber_id = subscr
    @product_id = product
    fetch_data
  end

  def fetch_data
    #see if we have a record of this lease already
    #maybe update other data members
  end

  def authorize #synonym for an open-ended lease
    #arguably, if a lease exists, we should keep the starts date
      #but since we're logging and not keeping a database, we'll just record
       #each distinct authorization
    @starts = Time.now.strftime('%F') #YYYY-MM-DD
    @expires = nil
  end

  def expire
    #a lease can't begin after it ends
    if @starts == nil || Date.parse(@starts) > Time.now.to_date
        @starts = Date.today.strftime('%F')
    end

    @expires = Time.now.strftime('%F') #YYYY-MM-DD
  end

  def status_at_host

  end

end
