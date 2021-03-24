# frozen_string_literal: true

require 'bundler/setup'
require 'slop'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/grant'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'product id', required: true
    opt.string '-s', '--subscriber', 'subscriber id (institution)'
    opt.string '-f', '--file', 'file with a list of subscriber ids'
    opt.bool   '-e', '--expire', 'Remove authorization (else )'
    opt.bool   '-n', '--nomail', "Suppress email to subscribers"
    opt.bool   '-i', '--instructions', 'Send instructions even for existing accounts (rare)'
    opt.bool   '-t', '--testing'
    opt.string '--name', 'Name of the institution'
    opt.string '--entityId', "entityId of the institution's Shibboleth entityId"
    opt.bool   '-h', '--help' do
      puts opts
    end
  end
rescue Slop::Error => err
  puts err
  puts 'Try -h or --help'
  exit
end

action = opts[:expire] ? :expire : :authz
ENV['GREENSUB_TEST'] = opts[:testing] ? '1' : '0'
ENV['GREENSUB_NOMAIL'] = opts[:nomail] ? '1' : '0'

product = Product.new(opts[:product])

unless product.hosted?
  puts "Product #{opts[:product]} does not have a host, quitting...."
  exit!(0)
end

subscrs = []
if opts[:subscriber] && opts[:file]
  puts "Pick one argument, either -s or -f"
  puts opts
elsif opts[:subscriber]
  subscrs.push opts[:subscriber]
elsif opts[:file]
  File.foreach(opts[:file]) { |l| subscrs.push l.chomp }
else
  puts "No subscribers specified"
  exit!(0)
end

subscrs.each do |s|
  subscr = if s.include? '@'
             Individual.new(s)
           else
             Institution.new(s, opts[:name], opts[:entityId])
           end
  grant = Grant.new(product, subscr)
  case action
  when :expire
    grant.expire!
  when :authz
    grant.create!( opts[:instructions] )
  end
end
