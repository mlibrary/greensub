# frozen_string_literal: true

require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/lease'

#Get params: inst_id, product_id, action
inst_id = '999'
product_id = 'heb'
action = :expire
$TESTING = true


product = Product.new(product_id)
unless product.hosted?
  puts " Product #{product} does not have a host, quitting...."
  exit!(0)
end

inst = Institution.new(inst_id)
lease = Lease.new(product, inst)

#if action is to expire
case action
when :authz
  if ! product.host.knows_subscriber(inst)
    unless product.host.add_subscriber(inst)
      abort "Can't add subscriber at host"
    end
  end
  lease.authorize
when :expire
  if ! product.host.knows_subscriber(inst)
    puts "Institution is not on the host, so nothing to expire"
    exit
  end
  lease.expire
end
