# frozen_string_literal: true

class Component
  attr_accessor :hosted_id, :sales_id, :find_hosted_id_flag, :name, :open_access, :product

  def initialize(ext_id, s_id, flag, prod_obj, name = nil)
    @hosted_id = ext_id # NOID
    @sales_id = s_id
    @find_hosted_id_flag = flag || false
    @name = name || nil
    @product = prod_obj

    if find_hosted_id_flag
      find_hosted_id
    end
  end

  def hosted?
    @product.host.knows_component?(self)
  end

  def remove_from_host
    @product.host.delete_component(self)
  end

  def find_hosted_id
    results = product.host.find_component_external_ids_by_identifier(@sales_id)
    if results.length == 1
      @hosted_id = results[0]['id']
    else
      abort "Multiple matches for #{identifier} at #{host.name}: #{results.inspect}"
    end
  end
end
