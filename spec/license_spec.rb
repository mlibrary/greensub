# frozen_string_literal: true

require 'date'
require_relative '../lib/license'
require_relative '../lib/subscriber'
require_relative '../lib/product'
require_relative '../lib/host'

RSpec.describe License do
  ENV['GREENSUB_TEST'] = '1'
  ENV['GREENSUB_NOMAIL'] = '1'

  heb = Product.new('heb')
  entity_id = 'https://foo.edu/idp'

  random = rand(100_000..199_999)
  inst_id = "test_inst_#{random}"
  inst_name = "Test Institution #{inst_id}"
  inst = Institution.new(inst_id, inst_name, entity_id)
  inst_license = described_class.new(heb, inst)

  random = rand(100_000..199_999)
  inst_id = "test_inst_#{random}"
  inst_name = "Test Institution #{inst_id}"
  inst2 = Institution.new(inst_id, inst_name, entity_id)
  inst2_license = described_class.new(heb, inst2, type: :read)

  before do
    # Don't print status messages during specs
    allow($stdout).to receive(:puts)
    inst_license.product.host.delete_subscriber(inst_license.subscriber)
    inst2_license.product.host.delete_subscriber(inst2_license.subscriber)
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    inst_license.product.host.delete_subscriber(inst_license.subscriber)
    inst2_license.product.host.delete_subscriber(inst2_license.subscriber)
  end

  describe "for Institution" do
    it "is active and defaults to a full license" do
      expect(inst_license.create!).to be true
      expect(heb.host.get_product_subscriber_license_type(heb, inst)).to eq(:full)
    end

    it "makes sure the Institution exists on host" do
      expect(inst_license.product.host.knows_institution?(inst_license.subscriber)).to be(true)
    end

    it "is active and has a :read license" do
      expect(inst2_license.create!).to be true
      expect(heb.host.get_product_subscriber_license_type(heb, inst2)).to eq(:read)
    end
  end

  prod = Product.new('heb')
  data = YAML.load_file('config/tests.yaml')
  ENV['GREENSUB_NOMAIL'] = '0'
  indiv_id = data['subscribers']['individual']['email']
  indiv = Individual.new(indiv_id)
  indiv_license = described_class.new(prod, indiv)

  it "creates a new individual subscription" do
    indiv_license.create!
    expect(prod.host.knows_subscriber?(indiv)).to be(true)
    expect(prod.host.get_product_subscriber_license_type(prod, indiv)).to eq(:full)
  end

  it "expires an individual subscription" do
    indiv_license.delete!
    expect(prod.host.knows_subscriber?(indiv)).to be(true)
    expect(prod.host.get_product_subscriber_license_type(prod, indiv)).to eq(nil)
  end
end
