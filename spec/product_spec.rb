# frozen_string_literal: true

require_relative '../lib/product'
require_relative '../lib/component'

RSpec.describe Product do
  ENV['GREENSUB_TEST'] = '1'

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  describe "Example Product" do
    test = described_class.new('product1')
    it "has an external id" do
      expect(test.external_id).to eq("test_product1")
    end
    it "has a name" do
      expect(test.name).to eq("Test Product 1")
    end
    it "has a host" do
      expect(test.host.class).to eq(Host)
    end
    # MAY NEED TO CHANGE THE WAY COMPONENTS ARE CONSTRUCTED, CALLED
    # it "can add components from a comma separated list (no spaces)" do
    #   rows = ['abcd1234,heb00001', 'efgh5678,heb99991']
    #   test.add_components(rows)
    #   expect(test.components[0].hosted_id).to eq('abcd1234')
    #   expect(test.components[0].sales_id).to eq('heb00001')
    #   expect(test.components[1].hosted_id).to eq('efgh5678')
    #   expect(test.components[1].sales_id).to eq('heb99991')
    # end
    # it "can add components from a comma separated list (with spaces)" do
    #   rows = ['abcd1234, heb00001', 'efgh5678, heb99991']
    #   test.add_components(rows)
    #   expect(test.components[0].hosted_id).to eq('abcd1234')
    #   expect(test.components[0].sales_id).to eq('heb00001')
    #   expect(test.components[1].hosted_id).to eq('efgh5678')
    #   expect(test.components[1].sales_id).to eq('heb99991')
    # end
    # it "can add components from a tab separated list" do
    #   rows = ['abcd1234 heb00001', 'efgh5678  heb99991']
    #   test.add_components(rows)
    #   expect(test.components[0].hosted_id).to eq('abcd1234')
    #   expect(test.components[0].sales_id).to eq('heb00001')
    #   expect(test.components[1].hosted_id).to eq('efgh5678')
    #   expect(test.components[1].sales_id).to eq('heb99991')
    # end
  end

  describe "Known bad product" do
    it "fails gracefully if there's no data on the requested product" do
      # How to test this without abort interrupting further tests?
    end
  end
end
