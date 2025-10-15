require_relative '../lib/netenos'

# Set parameters
DELAY_MODEL = :int_multi
COMPILER = :ghdl
GTECH = "classic"
MAX_GATES_INPUTS = 2

def gen_gtech
  # Generate the gtech
  `mkdir gtech` unless File.exist?('gtech')
  Dir.chdir('gtech') do
    Netlist::generate_gtech(MAX_GATES_INPUTS)
    @vhdl_converter = Converter::ConvNetlist2Vhdl.new
    @vhdl_converter.gen_gtech(GTECH)

    Converter::VhdlCompiler.new.gtech_makefile('.', COMPILER)

    system('make -s')
  end
end

def load_blif
  # Load blif
  blif_loader = Converter::ConvBlif2Netlist.new
  blif_loader.gen_genlib
  @circ = blif_loader.convert("../circ.blif", truth_table_format: false)
  @circ.getNetlistInformations(DELAY_MODEL)
  @circ.get_dot_graph
end

def write_vhdl_description
  # Write vhdl description
  vhdl_converter = Converter::ConvNetlist2Vhdl.new
  vhdl_converter.generate(@circ, DELAY_MODEL)
end

def gen_stim_file 
  # Generate an exhaustive stimulation file
  stim_generator = Converter::GenStim.new(@circ)
  stim_generator.gen_exhaustive_trans_stim
  stim_generator.save_as_txt("stim.txt")
end

def gen_tb
  tb_generator = Converter::GenTestbench.new(@circ, 1, @circ.get_exact_crit_path_length(DELAY_MODEL))
  tb_generator.gen_testbench("stim.txt", 1, @circ.name, nil, transact: true)
end

def compile_sim_script
  # Generate the compile and simulate script
  script_generator = Converter::VhdlCompiler.new
  script_generator.circ_compile_script('./', @circ.name, [1], [COMPILER, :minimal_sig], gtech_path: "gtech")
end

def check_activity
  raise "Test failed: No \"activity\" file created !" unless File.exist?('activity')

  activity = File.read('activity')
  raise "Test failed: Incorrect activity obtained for test circuit !" unless activity == "1,1,1
2,0,0
3,0,0
4,0,0
5,0,0
6,0,1
7,0,1
8,1,0
9,1,0
10,1,0
11,1,0
12,1,0
13,1,0
14,2,1
15,0,1
16,0,0
17,0,0
18,0,1
19,0,1
20,1,0
21,1,0
22,1,0
23,1,0
24,1,0
25,1,0
26,2,1
27,0,1
28,0,1
29,0,1
30,1,0
31,1,0
32,1,0
33,1,0
34,1,0
35,1,0
36,2,1
37,0,0
38,1,1
39,1,1
40,1,1
41,1,1
42,1,1
43,1,1
44,0,0
45,1,1
46,0,0
47,0,0
48,0,0
49,0,0
50,1,1
51,1,1
52,0,0
53,0,0
54,1,1
55,1,1
56,1,1
57,0,1
"
end

def check_timing
  raise "Test failed: No \"timing\" file created !" unless File.exist?('timing')

  transi_distrib = File.read('timing')
  raise "Test failed: Incorrect transition distribution obtained for test circuit !" unless transi_distrib == "0,2
1,0
2,0
3,25
4,0
5,0
6,25
7,12
"
end

Dir.chdir("tests/tmp") do 
  gen_gtech
  load_blif
  write_vhdl_description
  gen_stim_file
  gen_tb
  compile_sim_script
  `./compile.sh`
  check_activity
  check_timing
end
