<<<<<<< 4b7b754eedd9eb31bf377e00adbd5f7b4eb4b951
# frozen_string_literal: true

=======
>>>>>>> Basic Product class and tests.
require 'Product'

RSpec.describe Product do
  describe "Example Product" do
<<<<<<< 4b7b754eedd9eb31bf377e00adbd5f7b4eb4b951
    test = Product.new('test')
    it "has an external id" do
      expect(test.external_id).to eq("foo")
    end
    it "has a name" do
      expect(test.name).to eq("Foo Means Fake")
    end
    it "has a host" do
      expect(test.host).to eq("example")
=======
    heb = Product.new('heb')
    it "has an external id" do
      expect(heb.external_id).to eq("heb")
    end
    it "has a name" do
      expect(heb.name).to eq("ACLS Humanities E-Book")
>>>>>>> Basic Product class and tests.
    end
  end
end
