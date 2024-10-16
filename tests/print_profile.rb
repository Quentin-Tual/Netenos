require 'ruby-prof'

pp ARGV
prof = Marshal.load(IO.read(ARGV[0]))
printer = RubyProf::FlatPrinter.new(prof)
printer.print(STDOUT)