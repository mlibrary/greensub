# frozen_string_literal: true

require_relative '../lib/product'

#Get params: inst_id, product_id, action
inst_id = '111'
product_id = 'yoyo'
action = :authz
$TESTING = true


prod = Product.new(product_id)
unless prod.hosted?
  puts " Product #{prod} does not have a host, quitting...."
  exit!(0)
end

#prod.host.lessees

inst = Institution.new(inst_id)

if ! prod.host.knows_subscriber(inst)
    if action == :expire
      puts "Institution is not on the host, so nothing to expire"
      exit
    elsif action == :authz
        #create Inst on Host
        unless prod.host.add_subscriber(inst)
          abort "Can't add subscriber at host"
        end
    end
end

#if action is to expire
    #de-authz the inst to this product at the host
  #else
    #authz the inst at the host
#
