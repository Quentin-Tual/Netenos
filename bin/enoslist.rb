require 'optparse'
require "../lib/netlist.rb"

@options = {}
args = {}

OptionParser.new do |opts|

    Version = "Enoslist 0.1.0a (Feb 2023)"

    opts.on("-v", "--verbose", "Show extra information.") do
        @options[:verbose] = true
    end

    opts.on("-V", "--version", "Show used program current version.") do
        puts Version
    end

    # TODO : Ajouter une option pour le passage d'un JSON à la netlist

    # TODO : Ajouter une option pour le passage d'une netlist au JSON

    # TODO : Ajouter une option pour la converion netlist vers xdot

    # TODO : Ajouter une option pour la sérialisation (export) de la netlist

    # TODO : Ajouter une option pour l'import de la netlist sérialisée
    
end.parse!

