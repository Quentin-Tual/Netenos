require 'test/unit'
require 'benchmark'
require_relative '../lib/netenos.rb' 

class TestSerializationVsDeepCopy < Test::Unit::TestCase
  def setup
    # Create a moderately complex test circuit
    # @circuit = create_test_circuit(1000)  # 100 gates
    blifPath = "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/clip.blif"
    @circuit = Converter::ConvBlif2Netlist.new.convert(blifPath, truth_table_format: true)
    @serializer = Serializer.new
    @deserializer = Deserializer.new
    @tempfile = "test_circuit.sexp"
  end

  def teardown
    # Clean up temporary file
    File.delete(@tempfile) if File.exist?(@tempfile)
  end

  def test_performance_comparison
    serialization_time = 0
    deserialization_time = 0
    deep_copy_time = 0

    # Warm up
    @serializer.serialize(@circuit)
    @serializer.save_as(@tempfile)
    @deserializer.deserialize(@tempfile)
    @circuit.deep_copy

    # Measure performance
    Benchmark.bm(20) do |x|
      x.report("Serialization:") { serialization_time = measure_serialization }
      x.report("Deserialization:") { deserialization_time = measure_deserialization }
      x.report("Deep Copy:") { deep_copy_time = measure_deep_copy }
    end

    total_serdes_time = serialization_time + deserialization_time
    puts "\nComparison Results:"
    puts "  Serialization + Deserialization: #{total_serdes_time.round(6)}s"
    puts "  Deep Copy: #{deep_copy_time.round(6)}s"
    puts "  Difference: #{(total_serdes_time - deep_copy_time).round(6)}s (#{(total_serdes_time/deep_copy_time).round(2)}x)"

    # For CI/CD systems, we might want an assertion
    # This is just for demonstration - actual thresholds depend on your requirements
    assert_operator deep_copy_time, :<, total_serdes_time * 2,
      "Deep copy shouldn't be more than 2x slower than serialization/deserialization"
  end

  private

  def measure_serialization
    Benchmark.measure {
      @serializer.serialize(@circuit)
      @serializer.save_as(@tempfile)
    }.real
  end

  def measure_deserialization
    Benchmark.measure {
      @deserializer.deserialize(@tempfile)
    }.real
  end

  def measure_deep_copy
    Benchmark.measure {
      @circuit.deep_copy
    }.real
  end

  def create_test_circuit(gate_count)
    circuit = Netlist::Circuit.new("perf_test")
    
    # Add inputs
    inputs = []
    10.times do |i|
      input = Netlist::Port.new("in#{i}", :in)
      circuit << input
      inputs << input
    end

    # Add gates in a fanout structure
    gates = []
    gate_count.times do |i|
      gate = if i % 5 == 0
               Netlist::And2.new("and#{i}")
             elsif i % 5 == 1
               Netlist::Or2.new("or#{i}")
             elsif i % 5 == 2
               Netlist::Not.new("not#{i}")
             elsif i % 5 == 3
               Netlist::Nand2.new("nand#{i}")
             else
               Netlist::Nor2.new("nor#{i}")
             end
      circuit << gate
      gates << gate

      # Connect to random input or previous gate
      if i < 10
        source = inputs.sample
      else
        source = gates[rand(i)].get_output
      end
      gate.get_inputs[0] <= source
    end

    # Add outputs
    5.times do |i|
      output = Netlist::Port.new("out#{i}", :out)
      circuit << output
      output <= gates.sample.get_output
    end

    circuit
  end
end