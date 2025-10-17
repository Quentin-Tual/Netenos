module Verilog
  PDK_JSON=File.expand_path('sky130_fd_sc_hd_fixed.json',File.dirname(__FILE__))
end

require_relative 'verilog/v_ast'
require_relative 'verilog/v_lexer'
require_relative 'verilog/v_parser'
require_relative 'verilog/verilog_netlister'
require_relative 'verilog/nl2v'

