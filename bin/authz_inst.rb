# frozen_string_literal: true
require 'bundler/setup'
require 'slop'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/lease'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'product id', required: true
    opt.string '-s', '--subscriber', 'subscriber id (institution)', required: true
    opt.bool   '-e', '--expire', 'Remove authorization (else )'
    opt.bool   '-t', '--testing'
    opt.bool   '-h', '--help' do
      puts opts
    end
  end
rescue Slop::Error => e
  puts e
  puts 'Try -h or --help'
  exit
end

action = opts[:expire] ? :expire : :authz
ENV['GREENSUB_TEST'] = opts[:testing] ? '1' : '0'

product = Product.new( opts[:product] )

unless product.hosted?
  puts " Product #{opts[:product]} does not have a host, quitting...."
  exit!(0)
end

inst = Institution.new( opts[:subscriber] )
lease = Lease.new(product, inst)

#if action is to expire
case action
when :authz
  if ! product.host.knows_subscriber(inst)
    unless product.host.add_subscriber(inst)
      abort "Can't add subscriber #{opts[:subscriber] } at host #{product.host.id}"
    end
  end
  lease.authorize
when :expire
  if ! product.host.knows_subscriber(inst)
    puts "Institution #{opts[:subscriber]} is not on host #{product.host.id}, so nothing to expire"
    exit
  end
  lease.expire
end
