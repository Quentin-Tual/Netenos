#! /usr/env/bin ruby    

require_relative "../lib/netenos.rb"
# require 'ruby-prof'

# result = RubyProf.profile do
include Netlist

class Test_InsertBufferAt
    
    def initialize
    
        load_blif

        # gen_case 

        @tamperer = Inserter::Tamperer.new(@circ, @circ.get_netlist_precedence_grid)
    end

    def load_blif
        blif_converter = Converter::ConvBlif2Netlist.new
        @circ = blif_converter.convert "/home/quentint/Workspace/Benchmarks/Favorites/LGSynth91/MCNC/Combinational/blif/C17.blif"
        pp @circ.getNetlistInformations($DELAY_MODEL)
        @circ.get_exact_crit_path_length($DELAY_MODEL)
        @circ.get_slack_hash
        @viewer = Converter::DotGen.new
        @viewer.dot @circ, "#{@circ.name}.dot", $DELAY_MODEL
    end

    def run 
        insert_points = @circ.get_insertion_points($BUF_DELAY)
        @modified = @tamperer.insert_buffer_at(insert_points[4], $BUF_DELAY)

        # begin
        #     attempts ||= 0
        #     @modified = @modifier.insert2 
        #     puts "Modified circuit has combinational loop: #{@modified.has_combinational_loop?}"
        # rescue Inserter::ImpossibleInsertion, Inserter::ImpossibleResolution
        #     if $VERBOSE
        #         puts "Insertion attempt number #{attempts}"
        #     end

        #     if (attempts += 1) < 5
        #         gen_case
        #         retry
        #     else 
        #         raise "Error : Unable to insert with given netlist generation parameters"
        #     end
        # end

        # puts @tamperer.get_ht_stage


        pp @modified.getNetlistInformations($DELAY_MODEL)
        @viewer.dot(@modified, "#{@circ.name}_mod.dot", $DELAY_MODEL)

    end

    def gen_case 
        @generator = Netlist::RandomGenComb.new 7, 7, 8, [:even, 0.75]
        @circ = @generator.getRandomNetlist "test"
        puts "Original circuit has combinational loop: #{@circ.has_combinational_loop?}"
        pp @circ.getNetlistInformations :int_multi
        @timings_h = @circ.get_timings_hash
        @slack_h = @circ.get_slack_hash
        # generator = nil

        @viewer = Converter::DotGen.new
        @viewer.dot @circ, "./rand_circ.dot"

        @modifier = Inserter::Tamperer.new(@circ.clone, @generator.grid, @timings_h)
        @modifier.select_ht("og_s38417")
    end

end


if __FILE__ == $0
    # $CIRC_CARAC = [6, 3, 10, [:even, 0.70]]
    $DELAY_MODEL = :one
    $COMPILER = :ghdl3
    $BUF_DELAY = 1
    # $FREQ = 1

    Dir.chdir("tests/tmp") do
        puts "Lancement #{__FILE__}" 
        'rm *'
        # print(self.class)
        env = Test_InsertBufferAt.new 
        env.run
        puts "Fin #{__FILE__}"
    end
end

# end
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(STDOUT)