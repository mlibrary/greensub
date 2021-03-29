# frozen_string_literal: true

require 'slop'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/component'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'product id'
    opt.string '-i', '--id', 'external id of component (i.e. its id on the host service)'
    opt.string '-s', '--sales_id', 'sales id of component (i.e. the id when selling access, e.g. ISBN)'
    opt.string '-f', '--file', 'csv or tab delimeted file of components: $id, $sales_id'
    opt.bool   '-r', '--remove', 'Remove components from product'
    opt.bool   '-t', '--testing'
    opt.bool   '-l', '--lookup', 'lookup hosted id by the sales id'
    opt.bool   '-d', '--delete', 'Delete component from host (unrestricts item)'
    opt.bool   '-h', '--help' do
      puts opts
    end
  end
rescue Slop::Error => e
  puts e
  puts 'Try -h or --help'
  exit
end

ENV['GREENSUB_TEST'] = opts[:testing] ? '1' : '0'

product = Product.new(opts[:product])

unless product.hosted?
  puts "Product #{opts[:product]} does not have a host, quitting...."
  exit!(0)
end

rows = []
if opts[:file] && (opts[:id] || opts[:sales_id])
  puts "Either define one component with -e [-s], or multiple with -f"
  puts opts
elsif opts[:lookup] && opts[:sales_id] && opts[:id]
  puts "Don't use --lookup if you already have the --id"
elsif opts[:file]
  puts "got a file"
  File.foreach(opts[:file]) { |l| rows.push l.chomp }
elsif opts[:id]
  rows.push "#{opts[:id]},#{opts[:sales_id]}"
elsif opts[:lookup] && opts[:sales_id]
    rows.push "#{opts[:sales_id]}"
else
  puts "Incompatible options, so can't restrict component"
end

rows.each do |r|
  if opts[:lookup]
    sales_id = r.strip
    component = Component.new(nil, sales_id, opts[:lookup], product)
  else
    fields = r.split(/[,\s]+/) # handle both tabs and commas
    id = fields[0].tr_s('"', '').tr_s("''", '').strip
    sales_id = fields[1].tr_s('"', '').tr_s("''", '').strip
    component = Component.new(id, sales_id, opts[:lookup],    product)
  end
  begin
    if opts[:remove]
      product.remove(component)
    elsif opts[:delete]
      component.remove_from_host
    else
      product.add(component)
    end
  rescue StandardError => e
    STDERR.puts e.message
  end
end
