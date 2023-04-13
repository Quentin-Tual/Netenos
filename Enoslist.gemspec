Gem::Specification.new do |spec|
    spec.name        = 'Enoslist'
    spec.version     = '0.1.0'
    spec.summary     = 'A Netlist modelisation and tools associated.'
    spec.description = 'Enoslist is a Netlist modelisation developped in order to learn and experiment. For the moment, it does not modelize registers, but can be used for combinatorial logic. Also it embbed some tools to convert in other format (json, .dot, vhdl93, ...) or to generate random netlist, also to insert logic, ...'
    spec.authors     = ['QuentinT']
    spec.email       = 'quentintual2@gmail.com'
    spec.homepage    = 'https://github.com/Quentin-Tual/Hyle'
    spec.license     = 'MIT'
  
    spec.files       = Dir['lib/*','bin']
    spec.require_paths = ['lib','bin']
  end
  