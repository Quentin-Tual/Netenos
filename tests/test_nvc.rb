#! /usr/env/bin ruby
require_relative '../lib/netenos'
require_relative './test_compTbTraceComp'

$CIRC_CARAC = [8, 2, 10, [:custom, 0.70]]
$DELAY_MODEL = :int_multi
$FREQ = 10
$COMPILER = :ghdl
$OPT = [$COMPILER, :all_sig]

if __FILE__ == $0
  Dir.chdir('tmp') do
    puts "Lancement #{__FILE__}"
    Test_compTbTraceCompt.new
    puts "Fin #{__FILE__}"
  end
end
