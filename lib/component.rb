# frozen_string_literal: true

class Component
  attr_accessor :hosted_id, :sales_id, :name, :open_access, :product

  def initialize(ext_id, s_id, prod_obj, name = nil)
    @hosted_id = ext_id # NOID
    @sales_id = s_id || nil
    @name = name || nil
    @product = prod_obj
  end

  def hosted?
    @product.host.knows_component?(self)
  end

  def remove_from_host
    @product.host.delete_component(self)
  end
end
