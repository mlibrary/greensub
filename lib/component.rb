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

    handle_bar_number_sales_id
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
    elsif results.length == 0
        abort "No matches for #{@sales_id} at #{product.host.name}: #{results.inspect}"
    else
      abort "Multiple matches for #{@sales_id} at #{product.host.name}: #{results.inspect}"
    end
  end
end

def handle_bar_number_sales_id
  #Unlike other Monograph identifiers, BAR numbers have a prefix, but ve've
  # already created Components with Sales IDs of BAR numbers without those prefixes.
  # Until we remove the sales IDs altogether, handle this special case by trimming
  # off the prefix after we've had the chance to use it to do the NOID lookup.
  s = @sales_id.dup
  s.slice! 'bar_number:'
  @sales_id = s
end
