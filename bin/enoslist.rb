require 'optparse'
require_relative "../lib/netlist.rb"

@options = {}
@args = {}

OptionParser.new do |opts|

    Version = "Enoslist 0.1.0a (Feb 2023)"

    opts.on("-v", "--verbose", "Show extra information.") do
        @options[:verbose] = true
    end

    opts.on("-V", "--version", "Show used program current version.") do
        puts Version
    end

    # TODO : Ajouter une option pour l'import de la netlist sérialisée
    # TODO : Ajouter une option pour le passage d'un JSON à la netlist
    # ! : Pour le format, voir en ajoutant une autre option, plus simple en revanche serait préférable en ayant un requirement sur les options d'import ou d'export pour que la commande de format ait un sens.
    opts.on("-i FORMAT,FILE", "--import=FORMAT,FILE1,FILE2,...", Array, "Import a Netlist from one to multiple files in a specified format.") do |passed_args|
        @options[:import] = true
        @args[:import] = {:format => passed_args[0]}
        passed_args.shift 
        @args[:import][:files] = passed_args
    end

    # TODO : Ajouter une option pour le passage d'une netlist au JSON
    opts.on("-e FILE,FORMAT", "--export=FILE,FORMAT", Array, "Export a Netlist to a specified format in a file with the given name.") do |passed_args|
        @options[:export] = true
        @args[:export] = {:format => passed_args[1], :file => passed_args[0]}
        # TODO : Ajouter une option pour la sérialisation (export) de la netlist -> Un export avec marshal se fera via une valeur 'nil' par défaut
    end

    # TODO : Ajouter une option pour la converion netlist vers xdot
    opts.on("-s", "--show", "Export the current Netlist to .dot format.") do
        @options[:show] = true
        # ? Voir si on ajoute un nom ou pas pour préciser l'entité à visualiser, sûrement plus pratique
    end

end.parse!

pp @args

