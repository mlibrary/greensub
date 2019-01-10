class Component
  attr_accessor :hosted_id, :sales_id, :name, :handle, :open_access, :product

  def initialize( ext_id, s_id, prodObj, name=nil)
    @hosted_id = ext_id #NOID
    @sales_id = s_id ? s_id : nil
    @name = name ? name : nil
    @handle = get_handle(@hosted_id)
    @product = prodObj
  end

  def hosted?
    @product.host.knows_component?(self)
  end

  def get_handle(hosted_id)
      return "2027/fulcrum.#{hosted_id}"
  end

end
