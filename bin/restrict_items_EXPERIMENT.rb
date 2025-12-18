# frozen_string_literal: true

require 'slop'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/component'

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'product ID'
    opt.string '-i', '--id', 'external ID of component (i.e. its ID on the host service)'
    opt.string '-o', '--other_id', 'other identifier of component (i.e. the id when selling access, e.g. ISBN). May not be unique at the host.'
    opt.string '-f', '--file', 'csv or tab delimeted file of ID (as defined at host)'
    opt.bool   '-r', '--remove', 'Remove components from product'
    opt.bool   '-t', '--testing'
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

ids = []
find_hosted_id_flag = false
if opts[:file] && (opts[:id] || opts[:other_id])
  puts "Either define one component with -e [-o], or multiple with -f"
  puts opts
elsif opts[:file]
  puts "got a file"
  File.foreach(opts[:file]) { |l| rows.push l.chomp }
elsif opts[:id]
  process_component(opts[:id], opts[:other_id])
elsif opts[:other_id]
  ids.push "#{opts[:other_id]}"
  find_hosted_id_flag = true
else
  puts "No id defined, so can't restrict component"
end

ids.each do |r|
  fields = r.split(/[,\s]+/) # handle both tabs and commas
  id = fields[0].tr_s('"', '').tr_s("''", '').strip
  other_id = fields[1].tr_s('"', '').tr_s("''", '').strip
  process_component(id, other_id)
end

def process_component(id, other_id)
  component = Component.new(id, sales_id, find_hosted_id_flag, product)
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
