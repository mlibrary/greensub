require 'Product'

RSpec.describe Product do
  describe "Example Product" do
    heb = Product.new('heb')
    it "has an external id" do
      expect(heb.external_id).to eq("heb")
    end
    it "has a name" do
      expect(heb.name).to eq("ACLS Humanities E-Book")
    end
  end
end
