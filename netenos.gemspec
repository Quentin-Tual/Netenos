Gem::Specification.new do |spec|
  spec.name        = 'Netenos'
  spec.version     = '0.1.0'
  spec.summary     = 'A Netlist modelisation and tools associated.'
  spec.description = 'Enoslist is a Netlist modelisation developped in order to learn and experiment. For the moment, it does not modelize registers, but can be used for combinatorial logic. Also it embbed some tools to convert in other format (json, .dot, vhdl93, ...) or to generate random netlist, also to insert logic, ...'
  spec.authors     = ['QuentinT']
  spec.email       = 'quentintual2@gmail.com'
  spec.homepage    = 'https://github.com/Quentin-Tual/Enoslist'
  spec.license     = 'GPL-3.0'

  spec.bindir = 'bin'
  spec.files = Dir['**/*.rb'] #Dir['lib/**/*.rb'] + Dir['bin/*'] + Dir['doc/*'] + Dir['lib/*.rb'] + Dir['Hyle/**/*.rb'] + Dir['Hyle/*.rb']
  spec.files += Dir['[A-Z]*']
  # spec.require_paths = ['Hyle']
  spec.add_runtime_dependency 'Hyle', '~> 0.1.0'
  spec.add_runtime_dependency 'oj'
  # spec.add_development_dependency 'Hyle'
end
  