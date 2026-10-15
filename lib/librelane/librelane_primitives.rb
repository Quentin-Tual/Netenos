# frozen_string_literal: true

module Librelane
  def self.get_pdk_name(s_name, nl)
    if s_name.include?('/')
      comp_name, port_name = s_name.split('/')
      comp = nl.get_component_named(comp_name)
      port_pdk_name = comp.scl_ios[port_name]
      "#{comp_name}_#{port_pdk_name}"
    else
      s_name
    end
  end
end
