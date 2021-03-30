# frozen_string_literal: true

require_relative '../lib/component'
require_relative '../lib/product'

RSpec.describe Component do
  ENV['GREENSUB_TEST'] = '1'

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  prod1 = Product.new('product1')
  prod1.create
  prod2 = Product.new('product2')
  prod2.create
  id_lookup_flag = false
  comp1 = described_class.new('kw52j9144', 'kw52j9144', id_lookup_flag, prod1) #Moby Dick

  it "knows the ID that an external host will know it by" do
    expect(comp1.hosted_id).to eq('kw52j9144')
  end
  it "knows the ID by which it is sold" do
    expect(comp1.sales_id).to eq('kw52j9144')
  end
  it "can get added to a first product" do
    prod1.add(comp1)
    expect(comp1).to be_hosted
    expect(prod1).to have_component(comp1)
  end
  it "can get added to a second product" do
    prod2.add(comp1)
    expect(comp1).to be_hosted
    expect(prod2).to have_component(comp1)
  end
  it "can get removed from products" do
    prod1.remove(comp1)
    expect(prod1).not_to have_component(comp1)
    prod2.remove(comp1)
    expect(prod2).not_to have_component(comp1)
  end

  id_lookup_flag = true
  comp3 = described_class.new(nil, 'bar_number:S241', id_lookup_flag, prod2)
  it "can find find its NOID if we only have a BAR Number" do
    expect(comp3.hosted_id).to eq('hd76s0609')
  end
  it "handles the special case where the BAR number is formatted differently in the sales_is and the Monograph metadata" do
    expect(comp3.sales_id).to eq('S241')
  end
end
