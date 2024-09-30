require_relative "../lib/netenos.rb"

circ = Converter::ConvBlif2Netlist.new.convert("C17.blif")
stim_generator = Converter::ComputeStim.new(circ,:int_multi)

an_input = circ.get_inputs[0]

e1 = Converter::Event.new(an_input, 1.0, "R")
e2 = Converter::Event.new(an_input, 1.5, "1")

pp stim_generator.is_convertible? [e1, e2]

e3 = Converter::Event.new(an_input, 2.0, "R")

pp stim_generator.is_convertible? [e1, e2, e3]

e3 = Converter::Event.new(an_input, 2.0, "F")

pp stim_generator.is_convertible? [e1, e2, e3]
