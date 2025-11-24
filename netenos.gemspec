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
  spec.files = Dir['**/*.rb'] 
  spec.files += Dir['[A-Z]*']
  spec.files += Dir['lib/converter/**/*.vhdl']
  spec.files += Dir['lib/converter/**/*.erb']
  spec.files += Dir['lib/converter/gtech.genlib']
  spec.files += Dir['lib/*.json']

  spec.add_runtime_dependency 'oj', '>= 3.0.0'
  spec.add_runtime_dependency 'sxp'
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'pycall'
  spec.add_runtime_dependency 'fileutils'

  spec.add_development_dependency 'rspec'
end
  