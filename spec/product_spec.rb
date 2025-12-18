# frozen_string_literal: true

require_relative '../lib/product'
require_relative '../lib/component'

RSpec.describe Product do
  ENV['GREENSUB_TEST'] = '1'
  ENV['GREENSUB_NOMAIL'] = '1'

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
  end

  describe "Example Product" do
    test = described_class.new('product1')
    it "has an external id" do
      expect(test.external_id).to eq("product1")
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

  describe "BAR 2021" do
    bar = Product.new('bar_2021')

    random = rand(100_000..199_999)
    inst_id = "999#{random}"
    inst_name = "Test Institution #{inst_id}"
    inst = Institution.new(inst_id, inst_name)


    random = rand(100_000..199_999)
    inst_id = "999#{random}"
    inst_name = "Test Institution #{inst_id}"
    inst2 = Institution.new(inst_id, inst_name)

    before do
      # Don't print status messages during specs
      allow($stdout).to receive(:puts)
  #    inst_license.product.host.delete_subscriber(inst_license.subscriber)
  #    inst2_license.product.host.delete_subscriber(inst2_license.subscriber)
    end

    after(:all) do # rubocop:disable RSpec/BeforeAfterAl
  #    Delete all Licenses we created
  #    inst_license.product.host.delete_subscriber(inst_license.subscriber)
  #    inst2_license.product.host.delete_subscriber(inst2_license.subscriber)
    end

    it "creates only the specified License when an Institution is authorized" do
      expect(bar.create_license(inst, :full, :member)).to be true
      expect(bar.host.get_product_subscriber_license_type(bar, inst, :member)).to eq(:full)
      expect(bar.create_license(inst, :read, :alum)).to be true
      expect(bar.host.get_product_subscriber_license_type(bar, inst, :alum)).to eq(:read)
      expect(bar.host.get_product_subscriber_license_type(bar, inst, :wak_in)).to be_nil
    end
  end
end
