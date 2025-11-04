require 'json'

require_relative 'lib_extraction'
include Liberty

$DEBUG = true

$start_t = Time.now
puts " > START"

def load_lib path
  puts " > Loading library #{path}"
  lib = LibertyLibrary.new(path)
  lib_t = Time.now
  puts " > Library loaded in #{lib_t - $start_t} seconds"
  lib
end

def extract_functions lib
  functions_h = {}
  puts " > Extracting function names"
  cells = lib.cells
  cells.each do |c|
    cell_name = c.name.tr('"','')
    # next unless functions_h[cell_name].nil? 
    functions_h[cell_name] = {}
    outputs = c.outputs
    outputs.each do |op|
      op_name = op.name.tr('"','')
      op_fun = op.function.tr('"','')
      if functions_h[cell_name][op_name]
        if functions_h[cell_name][op_name] != op_fun 
          pp functions_h[cell_name][op_name]
          raise "Two different functions encountered for the same cell output #{cell_name}/#{op_name} : #{functions_h[cell_name][op_name]} =/= #{op_fun}"
        else
          next# Handle the situation when a StdCell has no given function (check when and if it can happen)
        end
      else
        functions_h[cell_name][op_name] = op_fun
      end
    end
  end
  fun_t = Time.now
  puts " > Function names extracted in #{fun_t - $start_t} seconds"
  functions_h
end

scl_path = "/home/quentint/.ciel/sky130B/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
lib = load_lib(scl_path)
functions_h = extract_functions(lib)

puts " > Writing data to JSON"
File.write("../sky130_functions.json", JSON.pretty_generate(functions_h))
puts " > Written to JSON"

end_t = Time.now
puts " > END after #{end_t - $start_t} seconds"