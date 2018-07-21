# frozen_string_literal: true

require_relative '../lib/product'

#Get params: inst_id, product_id, action
inst_id = '2'
product_id = 'heb'
action = 'authz'
$TESTING = true


prod = Product.new(product_id)
unless prod.hosted?
  puts " Product #{prod} does not have a host, quitting...."
  exit!(0)
end

#prod.host.lessees

inst = Institution.new(inst_id)

unless prod.host.knows_subscriber(inst)
    #if action is to expire
      #exit -- nothing to do
    #else
      #if greensub has a record for inst
        #return false until we implement our datastore
      #else
        #if we can get the inst name from Keycard
          #add name to Inst object
        #else
          #are we testing?
            #supply a fake name
          #else
            #gets string from user
        #end
        #create Inst on Host
      #end
    #end
end

#if action is to expire
    #de-authz the inst to this product at the host
  #else
    #authz the inst at the host
#
