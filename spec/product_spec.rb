<<<<<<< eb17d18cc0993c795641a1d97e61bf7bc8eff715
<<<<<<< 4b7b754eedd9eb31bf377e00adbd5f7b4eb4b951
# frozen_string_literal: true

=======
>>>>>>> Basic Product class and tests.
=======
# frozen_string_literal: true

>>>>>>> Added Product.host
require 'Product'

RSpec.describe Product do
  describe "Example Product" do
<<<<<<< eb17d18cc0993c795641a1d97e61bf7bc8eff715
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
=======
    test = Product.new('test')
>>>>>>> Added Product.host
    it "has an external id" do
      expect(test.external_id).to eq("foo")
    end
    it "has a name" do
<<<<<<< eb17d18cc0993c795641a1d97e61bf7bc8eff715
      expect(heb.name).to eq("ACLS Humanities E-Book")
>>>>>>> Basic Product class and tests.
=======
      expect(test.name).to eq("Foo Means Fake")
    end
    it "has a host" do
      expect(test.host).to eq("example")
>>>>>>> Added Product.host
    end
  end
end
