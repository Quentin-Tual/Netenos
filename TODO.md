# TODO List

- [x] Add Verilog parser to Netenos
- [ ] Update BLIF parser to accept PDK cells like the Verilog parser
- [ ] Add SDF parser to Netenos
- [ ] Add SDF visitor to annotate netlist with delays
- [ ] Harmonize and simplify the `get_source[...]` functions, only one should be needed, or explicitly name it after what it is used for.
- [ ] Divide "Converter" in many directories, reorganize the project structure in lib/converter
- [ ] Add a circ descriptor for rise/fall delay model ?
- [ ] Refactor the data extracted from the netlist (all delays related data for example) to memorize them as external objects and not as attributes of the Circuit/Gate/Port class
- [ ] It might be possible to use a generic Delay or DelayModel object to store delays in a circuit, which would be the same for all different delay models used. It would be cleaner to use VHDL and classes implementing the most realistic delay model authorized and to use the same values in various fields for simpler usable delay models. 
- [ ] Use Visitor design pattern to explore the netlist (graph/tree style object). Possible for a lot of functionality (Code generation in various format, maybe delay calculations, etc).
- [ ] Build all classes (Gates and Wires) upon inheritance from a Node class (possibily an abstract class)
- [x] Change internal separator `_` for port full name with `/` for example, avoiding compatibility problems with future verilog files reading.   
- [ ] Create a FullPortName class ? Allow to manage full port name easier and to reduce verbosity
- [ ] Add PDK handling for technology mapping through abc (currently only for BLIF reading and verilog reading) 
- [ ] Add the functionnality and a rspec test for Verilog writing of a blif loaded netlist and back forth
- [ ] Add tests using RSpec for each functionnality (stick to a expected vs actual logic or high level view, only check behavior as a big picture at first) 
- [ ] Rename ATETA as HTPG