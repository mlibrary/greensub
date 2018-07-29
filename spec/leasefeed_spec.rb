# frozen_string_literal: true

require_relative '../lib/product'
require_relative '../lib/leasefeed'

RSpec.describe LeaseFeed do
  ENV['GREENSUB_TEST'] = '1'
  context "HEB's live individual subscriber feed" do
    product = Product.new('heb')
    feed = HEBLeasefeed.new(product)
    it "is donwloadable" do
      feed.fetch
      expect(feed.datastream).to_not be(nil)
    end
    it "is XML" do
      expect(feed.datastream.xml?).to be(true)
    end
    it "has at least 50 records" do
      expect(feed.datastream.xpath('/ACLSExport/acls').count).to be >= 50
    end

    describe "A new subscriber" do
      sub1_id = 'subscriber1@example.com'
      xml = "<?xml version=\"1.0\"?><ACLSExport><acls><id>1</id><firstname>Example</firstname><lastname>Subscriber</lastname><email>#{sub1_id}</email><phone>555-123-4567</phone><expirationdate>2525-01-01</expirationdate></acls></ACLSExport>"
      fakefeed = HEBLeasefeed.new(product)
      fakefeed.datastream = Nokogiri::XML(xml)
      sub1 = Subscriber.new(sub1_id)
      it "is authorized to the product" do
        fakefeed.parse
        expect(product.host.knows_subscriber?(sub1)).to be(true)
        expect(product.subscriber_can_access?(sub1)).to be(true)
      end
      it "is unauthorized when the expiration date is today" do
        xml2 = "<?xml version=\"1.0\"?><ACLSExport><acls><id>1</id><firstname>Example</firstname><lastname>Subscriber</lastname><email>#{sub1_id}</email><phone>555-123-4567</phone><expirationdate>#{Time.now.strftime('%F')}</expirationdate></acls></ACLSExport>"
        fakefeed.datastream = Nokogiri::XML(xml2)
        fakefeed.parse
        expect(product.subscriber_can_access?(sub1)).to be(false)
      end
    end
  end
end
