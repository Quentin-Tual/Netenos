require 'test/unit'
require_relative '../lib/netlist.rb'  # Assuming your files are in the same directory
require_relative '../lib/netlist/addon_deep_copy.rb'

class TestCircuitDeepCopy < Test::Unit::TestCase
  def setup
    # Create a simple original circuit: input -> AND -> OR -> output
    #                          input -> NOT -> OR
    @original = Netlist::Circuit.new("original")
    
    # Create ports
    @input = Netlist::Port.new("in1", :in)
    @output = Netlist::Port.new("out1", :out)
    
    # Create gates
    @and_gate = Netlist::And2.new("and1")
    @or_gate = Netlist::Or2.new("or1")
    @not_gate = Netlist::Not.new("not1")
    
    # Add components to circuit
    @original << @and_gate << @or_gate << @not_gate
    @original << @input
    @original << @output

    # Make connections
    @and_gate.get_inputs[0] <= @input
    @not_gate.get_inputs[0] <= @input
    @or_gate.get_inputs[0] <= @and_gate.get_output
    @or_gate.get_inputs[1] <= @not_gate.get_output
    @output <= @or_gate.get_output
  end

  def test_deep_copy_creates_new_instance
    copy = @original.deep_copy
    refute_equal @original.object_id, copy.object_id
    assert_equal "original_copy", copy.name
  end

  def test_deep_copy_has_identical_structure
    copy = @original.deep_copy
    
    # Verify same number of components
    assert_equal @original.components.size, copy.components.size
    
    # Verify all gates exist in copy
    %w[and1 or1 not1].each do |name|
      assert copy.get_component_named(name), "Component #{name} missing in copy"
    end
    
    # Verify connections are preserved
    copy_and = copy.get_component_named("and1")
    copy_or = copy.get_component_named("or1")
    copy_not = copy.get_component_named("not1")
    copy_input = copy.get_port_named("in1")
    copy_output = copy.get_port_named("out1")
    
    # Verify connections
    assert_equal copy_input, copy_and.get_inputs[0].get_source
    assert_equal copy_input, copy_not.get_inputs[0].get_source
    assert_equal copy_and.get_output, copy_or.get_inputs[0].get_source
    assert_equal copy_not.get_output, copy_or.get_inputs[1].get_source
    assert_equal copy_or.get_output, copy_output.get_source
  end

  def test_deep_copy_is_independent
    copy = @original.deep_copy
    
    # Modify the copy
    new_not = Netlist::Not.new("not2")
    copy << new_not
    new_not.get_inputs[0] <= copy.get_port_named("in1")
    copy.get_component_named("and1").get_inputs[1] <= new_not.get_output
    
    # Verify original wasn't modified
    assert_equal 3, @original.components.size
    assert_nil @original.get_component_named("not2")
    assert_equal @not_gate.get_output, @or_gate.get_inputs[1].get_source
  end

  def test_deep_copy_with_modification
    copy = @original.deep_copy("modified_circuit")
    
    # Insert a new gate in the copy
    buffer = Netlist::Buffer.new(1.0, "buf1")
    copy << buffer
    
    # Connect: and1 -> buf1 -> or1
    and_gate = copy.get_component_named("and1")
    or_gate = copy.get_component_named("or1")
    
    # Disconnect original and1->or1 connection
    
    # source = and_gate.get_output
    # sink = and_gate.get_output.fanout.find { |s| s == or_gate.get_inputs[0] }

    or_gate.get_inputs[0].unplug2(and_gate.get_output.get_full_name)
    # sink.unplug2(source)
    
    # Make new connections
    buffer.get_inputs[0] <= and_gate.get_output
    or_gate.get_inputs[0] <= buffer.get_output
    
    # Verify original unchanged
    assert_equal 3, @original.components.size
    assert_equal @and_gate.get_output, @or_gate.get_inputs[0].get_source
    
    # Verify copy modified correctly
    assert_equal 4, copy.components.size
    copy_buffer = copy.get_component_named("buf1")
    assert_equal copy_buffer.get_inputs[0].get_source, and_gate.get_output
    assert_equal or_gate.get_inputs[0].get_source, copy_buffer.get_output
  end

  def test_deep_copy_preserves_properties
    # Set some properties on original
    @original.crit_path_length = 10
    @and_gate.propag_time = { custom: 5.0 }
    
    copy = @original.deep_copy
    
    # Verify properties are copied
    assert_equal 10, copy.crit_path_length
    copy_and = copy.get_component_named("and1")
    assert_equal 5.0, copy_and.propag_time[:custom]
    
    # Modify copy properties
    copy.crit_path_length = 20
    copy_and.propag_time = { custom: 10.0 }
    
    # Verify original unchanged
    assert_equal 10, @original.crit_path_length
    assert_equal 5.0, @and_gate.propag_time[:custom]
  end

  # NOT EXPECTED IN COMBINATIONAL NETLIST FOR NOW
#   def test_deep_copy_with_subcircuits
#     # Create hierarchy: top -> sub -> and_gate
#     top = Netlist::Circuit.new("top")
#     sub = Netlist::Circuit.new("sub")
#     and_gate = Netlist::And2.new("and1")
    
#     input = Netlist::Port.new("in1", :in)
#     output = Netlist::Port.new("out1", :out)
    
#     sub << and_gate
#     top << input 
#     top << output 
#     top << sub
    
#     # Connect
#     and_gate.get_inputs[0] <= input
#     output <= and_gate.get_output
    
#     # Make copy
#     copy = top.deep_copy
    
#     # Verify hierarchy
#     assert_equal "top_copy", copy.name
#     copy_sub = copy.components.find { |c| c.is_a?(Netlist::Circuit) }
#     assert_equal "sub_copy", copy_sub.name
#     assert copy_sub.get_component_named("and1")
    
#     # Verify connections
#     copy_input = copy.get_port_named("in1")
#     copy_output = copy.get_port_named("out1")
#     copy_and = copy_sub.get_component_named("and1")
    
#     assert_equal copy_input, copy_and.get_inputs[0].get_source
#     assert_equal copy_and.get_output, copy_output.get_source
#   end
end