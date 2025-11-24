$FULL_PORT_NAME_SEP='/'  
$PDK_IOS_JSON=File.expand_path('sky130_fd_sc_hd_fixed.json',File.dirname(__FILE__))
$PDK_FUN_JSON=File.expand_path('sky130_functions.json', File.dirname(__FILE__))

require 'erb'
require 'json'

require_relative 'util'
require_relative 'code'
require_relative 'visitor'
require_relative "netlist.rb"
require_relative "converter.rb"
require_relative "serializer/serdes.rb"
require_relative "interface.rb"
require_relative "inserter/tamper.rb"
require_relative "vcd.rb"
require_relative 'bexp/bexp'
require_relative 'smt'
require_relative 'sdf'
require_relative 'liberty'
require_relative 'verilog'
require_relative 'ateta'