require_relative '../lib/component'
require_relative '../lib/product'

RSpec.describe "Component" do

  ENV['GREENSUB_TEST'] = '1'

  prod1 = Product.new('product1')
  prod1.create
  prod2 = Product.new('product2')
  prod2.create
  comp1 = Component.new('abcd1234','qwerty',prod1)
  comp2 = Component.new('efgh5678','asdfg', prod2)



  it "knows the ID that an external host will know it by" do
    expect(comp1.hosted_id).to eq('abcd1234')
  end
  it "knows the ID by which it is sold" do
    expect(comp1.sales_id).to eq('qwerty')
  end
  it "can get added to a first product" do
    prod1.add(comp1)
    expect(comp1.hosted?).to be_truthy
    expect(prod1.has_component?(comp1)).to be_truthy
  end
  it "can get added to a second product" do
    prod2.add(comp1)
    expect(comp1.hosted?).to be_truthy
    expect(prod2.has_component?(comp1)).to be_truthy
  end
  it "can get removed from products" do
    prod1.remove(comp1)
    expect(prod1.has_component?(comp1)).to_not be_truthy
    prod2.remove(comp1)
    expect(prod2.has_component?(comp1)).to_not be_truthy
  end
end
