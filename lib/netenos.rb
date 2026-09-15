# frozen_string_literal: true

$FULL_PORT_NAME_SEP = '/'
$PDK_IOS_JSON = File.expand_path('sky130_fd_sc_hd_fixed.json', File.dirname(__FILE__))
$PDK_FUN_JSON = File.expand_path('sky130_functions.json', File.dirname(__FILE__))
$TMP_PATH = '/tmp/Netenos'

Dir.mkdir($TMP_PATH) unless Dir.exist?($TMP_PATH)

class Array
  def depth
    new = flatten(1)
    return 1 if new == self

    1 + new.depth
  end
end

require 'erb'
require 'json'
require 'fileutils'
require 'minitar'

require_relative 'util'
require_relative 'code'
require_relative 'visitor'
require_relative 'netlist'
require_relative 'delays'
require_relative 'converter'
require_relative 'serializer/serdes'
require_relative 'interface'
require_relative 'inserter/tamper'
require_relative 'vcd'
require_relative 'bexp/bexp'
require_relative 'sdf'
require_relative 'liberty'
require_relative 'verilog'
require_relative 'asp'
require_relative 'smt'
require_relative 'ateta'
require_relative 'librelane'
