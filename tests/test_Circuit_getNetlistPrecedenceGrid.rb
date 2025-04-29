require 'test/unit'
require_relative '../lib/netlist.rb'

class TestNetlistPrecedenceGrid < Test::Unit::TestCase
  def setup
    @circuit = Netlist::Circuit.new("test_circuit")
  end

  def test_empty_circuit
    grid = @circuit.get_netlist_precedence_grid
    assert_equal({}, grid)
  end

  def test_single_gate
    input = Netlist::Port.new("i0", :in)
    output = Netlist::Port.new("o0", :out)
    gate = Netlist::And2.new("and1")
    
    @circuit << input
    @circuit << output
    @circuit << gate
    
    # Connect input to gate
    gate.get_inputs[0] <= input
    # Connect gate to output
    output <= gate.get_output
    
    grid = @circuit.get_netlist_precedence_grid
    assert_equal(1, grid.size)
    assert_equal([gate], grid[0])
  end

  def test_two_gates_series
    input = Netlist::Port.new("i0", :in)
    output = Netlist::Port.new("o0", :out)
    gate1 = Netlist::And2.new("and1")
    gate2 = Netlist::Or2.new("or1")
    
    @circuit << input
    @circuit << output
    @circuit << gate1
    @circuit << gate2
    
    # Connect input to gate1
    gate1.get_inputs[0] <= input
    # Connect gate1 to gate2
    gate2.get_inputs[0] <= gate1.get_output
    # Connect gate2 to output
    output <= gate2.get_output
    
    grid = @circuit.get_netlist_precedence_grid
    assert_equal(2, grid.size)
    assert_equal([gate1], grid[0])
    assert_equal([gate2], grid[1])
  end

  def test_two_gates_parallel
    input = Netlist::Port.new("i0", :in)
    output1 = Netlist::Port.new("o0", :out)
    output2 = Netlist::Port.new("o1", :out)
    gate1 = Netlist::And2.new("and1")
    gate2 = Netlist::Or2.new("or1")
    
    @circuit << input
    @circuit << output1
    @circuit << output2
    @circuit << gate1
    @circuit << gate2
    
    # Connect input to both gates
    gate1.get_inputs[0] <= input
    gate2.get_inputs[0] <= input
    # Connect both gates to output
    output1 <= gate1.get_output
    output2 <= gate2.get_output
    
    grid = @circuit.get_netlist_precedence_grid
    assert_equal(1, grid.size)
    assert_equal([gate1, gate2].to_set, grid[0].to_set)
  end

  def test_complex_structure
    # Create a more complex circuit: input -> and1 -> or1 -> output
    #                          input -> and2 -> or1
    input = Netlist::Port.new("i0", :in)
    output = Netlist::Port.new("o0", :out)
    and1 = Netlist::And2.new("and1")
    and2 = Netlist::And2.new("and2")
    or1 = Netlist::Or2.new("or1")
    
    @circuit << input
    @circuit << output
    @circuit << and1
    @circuit << and2
    @circuit << or1
    
    # Connect input to and1 and and2
    and1.get_inputs[0] <= input
    and2.get_inputs[0] <= input
    # Connect and1 to or1
    or1.get_inputs[0] <= and1.get_output
    # Connect and2 to or1
    or1.get_inputs[1] <= and2.get_output
    # Connect or1 to output
    output <= or1.get_output
    
    grid = @circuit.get_netlist_precedence_grid
    assert_equal(2, grid.size)
    assert_equal([and1, and2].to_set, grid[0].to_set)
    assert_equal([or1], grid[1])
  end

  def test_memoization
    input = Netlist::Port.new("i0", :in)
    output = Netlist::Port.new("o0", :out)
    gate = Netlist::And2.new("and1")
    
    @circuit << input
    @circuit << output
    @circuit << gate
    
    gate.get_inputs[0] <= input
    output <= gate.get_output
    
    # First call should compute
    grid1 = @circuit.get_netlist_precedence_grid
    # Second call should return cached result
    grid2 = @circuit.get_netlist_precedence_grid
    
    assert_equal(grid1.object_id, grid2.object_id, "Memoization failed - grid was recomputed")
  end
end