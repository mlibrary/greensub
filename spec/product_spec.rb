# frozen_string_literal: true

require_relative '../lib/product'

RSpec.describe Product do
  describe "Example Product" do
    test = Product.new('test')
    it "has an external id" do
      expect(test.external_id).to eq("foo")
    end
    it "has a name" do
      expect(test.name).to eq("Foo Means Fake")
    end
    it "has a host" do
      expect(test.host.class).to eq(Host)
    end
  end
  describe "Known bad product" do
    it "fails gracefully if there's no data on the requested product" do
       #How to test this without abort interrupting further tests?
    end
  end
end
