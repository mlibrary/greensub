class Component
  attr_accessor :hosted_id, :sales_id, :open_access, :product

  def initialize( ext_id, s_id, prodObj )
    @hosted_id = ext_id
    @sales_id = s_id
    @product = prodObj
  end

  def hosted?
    @product.host.knows_component?(self)
  end

end
