$FULL_PORT_NAME_SEP='/'  
$PDK_JSON=File.expand_path('sky130_fd_sc_hd_fixed.json',File.dirname(__FILE__))

require 'erb'
require 'json'

require_relative 'code'
require_relative 'visitor'
require_relative "netlist.rb"
require_relative "converter.rb"
require_relative "interface.rb"
require_relative "inserter/tamper.rb"
require_relative "vcd.rb"
require_relative "ateta.rb"
require_relative "serializer/serdes.rb"
require_relative 'verilog'
require_relative 'sdf'