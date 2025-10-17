$FULL_PORT_NAME_SEP='/'  

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