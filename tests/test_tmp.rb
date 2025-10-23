require_relative '../lib/netenos'

puts "START"
TEST_SDF_FILE='tests/sdf/mapped_xor5__nom_tt_025C_1v80.sdf'
TEST_V_FILE='tests/verilog/xor5_prepnr.nl.v'
DELAY_MODEL=:sdf
SIMPLIFIER_FUN=:max

NETLIST = Verilog.load_netlist(TEST_V_FILE)
SDF.annotate(NETLIST,TEST_SDF_FILE)

NETLIST.getNetlistInformations(DELAY_MODEL)
slack_h = NETLIST.get_slack_hash
timings_h = NETLIST.get_timings_hash(DELAY_MODEL)
precedence_grid = NETLIST.get_netlist_precedence_grid
altered = NETLIST.deep_copy
attacker = Inserter::Tamperer.new(altered,precedence_grid,timings_h,delay_model: DELAY_MODEL)
min_delay = altered.get_comp_min_delay(DELAY_MODEL)
insertion_points = altered.get_insertion_points(min_delay)
loc = insertion_points.first
delay_h = {sdf: min_delay}
altered = attacker.insert_sky130_buffer_at(loc, delay_h)



Converter::DotGen.new.dot(
            NETLIST, 
            "tests/tmp/test_initial_tmp.dot", 
            DELAY_MODEL
          )
Converter::DotGen.new.dot(
            altered, 
            "tests/tmp/test_altered_tmp.dot", 
            DELAY_MODEL
          )

puts "END"