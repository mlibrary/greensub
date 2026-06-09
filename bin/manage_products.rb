# frozen_string_literal: true

require 'bundler/setup'
require 'slop'
require 'csv'
require_relative '../lib/product'
require_relative '../lib/subscriber'
require_relative '../lib/license'

def value_for(record, field)
  if record.key?(field)
    record[field]
  elsif record.key?(field.to_sym)
    record[field.to_sym]
  end
end

def output_records(records, fields:, raw: false)
  records = Array(records)

  if raw
    puts records
  else
    records.each do |record|
      print CSV.generate_line(fields.map { |field| value_for(record, field) })
    end
  end
end

begin
  opts = Slop.parse strict: true do |opt|
    opt.string '-p', '--product', 'Product Identifier', required: true
    opt.string '--pname', 'Name of the Product'
    opt.string '-u', '--url', 'Purchase URL for Product'
    opt.string '-a', '--action', 'Action to perform'
    opt.string '-s', '--subscriber', 'subscriber id (institution)'
    opt.string '-f', '--file', 'file with a list of component ids'
    opt.bool   '-t', '--testing'
    opt.string '-c', '--component', 'Component Identifier'
    opt.string '-n', '--noid', 'NOID of the Component Monograph'
    opt.string '--sales_id', 'sales ID of the Component Monograph'
    opt.string '--cname', 'Name of the Component'
    opt.bool   '--raw', 'Output original Ruby hash output instead of CSV'
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

product = Product.new(opts[:product]) if opts[:product]
component = Component.new(opts[:component]) if opts[:component]

unless product.hosted?
  puts "Product #{opts[:product]} does not have a host, quitting...."
  exit!(0)
end

rows = []
File.foreach(opts[:file]) { |l| rows.push l.chomp } if opts[:file]

action = opts[:action]
output = '' # rubocop:disable Lint/UselessAssignment

case action
when 'exists'
  if product
    product.hosted?
  elsif component
    component.hosted?
  end

when 'list_components'
  output_records(
    product.list_components,
    fields: %w[noid identifier],
    raw: opts[:raw]
  )

when 'list_institutions'
  output_records(
    product.list_institutions,
    fields: %w[identifier name],
    raw: opts[:raw]
  )

when 'list_licenses'
  puts product.list_licenses

when 'list_individuals'
  output = product.list_individuals
  output.each do |i|
    puts i['identifier']
  end

when 'component_info'
  if opts[:file]
    puts 'got a file'
    File.foreach(opts[:file]) { |l| rows.push l.chomp }
  elsif opts[:noid]
    rows.push "#{opts[:noid]},#{opts[:sales_id]}"
  else
    abort 'No component ID to check'
  end

  rows.each do |r|
    fields = r.split(/[,\s]+/) # handle both tabs and commas
    id = fields[0].tr_s('"', '').tr_s("''", '').strip
    sales_id = fields[1].tr_s('"', '').tr_s("''", '').strip
    component = Component.new(id, sales_id, Product)

    begin
      puts "#{id} (#{sales_id}): ", product.host.knows_component?(component)
    rescue StandardError => e
      puts e
    end
  end

when 'add'
  if condition # rubocop:disable Lint/EmptyConditionalBody

  end
end