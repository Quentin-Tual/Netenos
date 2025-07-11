Gem::Specification.new do |spec|
  spec.name        = 'Netenos'
  spec.version     = '0.5.9'
  spec.summary     = 'A Netlist modelisation and tools associated.'
  spec.description = 'Netenos is a Netlist modelisation developped in order to learn and experiment. For the moment, it does not modelize registers, but can be used for combinatorial logic. Also it embbed some tools to convert in other format (json, graphviz .dot, vhdl93, ...), to generate random netlist or also to insert logic, ...'
  spec.authors     = ['QuentinT']
  spec.email       = 'quentintual2@gmail.com'
  spec.homepage    = 'https://github.com/Quentin-Tual/Netenos'
  spec.license     = 'GPL-3.0-only'

  spec.bindir = 'bin'
  spec.files = Dir['**/*.rb'] #Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['doc/*'] + Dir['lib/*.rb'] + Dir['Hyle/**/*.rb'] + Dir['Hyle/*.rb']
  spec.files += Dir['[A-Z]*']
  spec.files += Dir['lib/converter/**/*.vhdl']
  spec.files += Dir['lib/converter/**/*.erb']
  # spec.files += Dir['lib/converter/tb_template3.vhdl']
  # spec.files += Dir['lib/converter/tb_comp_template.vhdl']
  # spec.files += Dir['lib/converter/tb_detect_template.vhdl']
  spec.files += Dir['lib/converter/gtech.genlib']
  # spec.require_paths = ['Hyle']
  # spec.add_runtime_dependency 'Hyle', '~> 0.1.0'
  spec.add_runtime_dependency 'oj', '>= 3.0.0'
  spec.add_runtime_dependency 'sxp'

  # spec.add_development_dependency 'Hyle'
end
  