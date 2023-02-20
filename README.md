# Enoslist

This project is a small attempt to create a tool in order to import, export and modify netlists.
It is wanted to allow different format for the import and the export.
The netlist modification aims to be as permissive as possible.

There is just a few usage rules fixed to simplify development :
    - Assignments are always done from output to inputs using the '<=' symbol
    - At the moment all Inputs and Outputs existing must be connected, else an error is raised 
    - Custom classes should be based on classes described in circuit.rb (especially on Circuit class). These custom classes can be defined in another Ruby file then included in "netlist.rb". 