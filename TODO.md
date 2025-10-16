# TODO List

- [ ] Divide "Converter" in many directories, reorganize the project structure in lib/converter
- [ ] Refactor the data extracted from the netlist (all delays related data for example) to memorize them as external objects and not as attributes of the Circuit/Gate/Port class
- [ ] It might be possible to use a generic Delay or DelayModel object to store delays in a circuit, which would be the same for all different delay models used. It would be cleaner to use VHDL and classes implementing the most realistic delay model authorized and to use the same values in various fields for simpler usable delay models. 
