require 'optparse'
require_relative "../lib/netlist.rb"

# TESTS : 
require_relative "../tests/test_lib.rb"

@options = {}
@args = {}

ARGV << '-h' if ARGV.empty?

OptionParser.new do |opts|

# TODO 1 : Tester si les derniers ajouts fonctionnent tous correctement.
# TODO 2 : rendre l'aide (banner) plus claire pour l'utilisateur avec un exemple ou deux.
# TODO 3 : Utiliser l'option de verbosité lorsque possible 
# TODO 4 : Placer le fichier temporaire ~.enl dans /tmp (plus propre et transparent)


    Version = "Enoslist 0.1.0a (Feb 2023)"

    opts.on("-v", "--verbose", "Show extra information.") do
        @options[:verbose] = true
    end

    opts.on("-V", "--version", "Show used program current version.") do
        @options[:version] = true
        puts Version
    end

    # TODO : Ajouter une option pour l'import de la netlist sérialisée
    # TODO : Ajouter une option pour le passage d'un JSON à la netlist
    opts.on("-i FILE", "--import=FILE", "Import a Netlist from one file in a specified format.") do |passed_args|
        @options[:import] = true
        @args[:import] = {:file => passed_args}
        # * : Vérification d'une éventuelle commande courte précédente, complétion des informations manquantes.
        if @options[:export] and not(@options[:exp_format])
            @options[:exp_format] = true
            @args[:export][:format] = "def"
        end
    end

    # TODO : Ajouter une option pour le passage d'une netlist au JSON
    opts.on("-e FILE", "--export=FILE","Export a Netlist to a specified format (-f option) in a file with the given name.") do |passed_args|
        @options[:export] = true
        @args[:export] = {:file => passed_args}
        
        if @options[:import] and not(@options[:imp_format])
            @options[:imp_format] = true
            @args[:import][:format] = "def"
        end
    end

    # TODO : Voir si possible d'obtenir plusieurs formats différents pour les imports multiples
    # ? : Optimisation possible en supprimant le format s'il vaut 'def' ? Potentiellement intéressant, à explorer.
    opts.on("-f FORMAT", "--format=FORMAT", ['json','dot','vhdl','def'], "Allow to specify format for import and export.") do |format|
        # * : Sélection de la situation pour associer le format à la bonne opération entre l'import et l'export.
        if  not(@options[:import] or @options[:export])
            raise "ERROR : format option must be used after an import or export option."
        elsif @options[:import] and not(@options[:export])
            @options[:imp_format] = true
            @args[:import][:format] = format
        elsif not(@options[:import]) and @options[:export]
            @options[:exp_format] = true
            @args[:export][:format] = format
        # * : Si les deux options ont déjà été rencontrées, l'une d'entre elle est au format implicite (format par défaut).
        elsif @options[:import] and @options[:export]
            if not(@args[:import][:format].nil?) and @args[:export][:format].nil?
                @options[:exp_format] = true
                @args[:export][:format] = format
            elsif (@args[:import][:format].nil? and not(@args[:export][:format].nil?)) or (@args[:import][:format].nil? and @args[:export][:format].nil?)
                @options[:imp_format] = true
                @args[:import][:format] = format
            end
        end
    end

    # TODO : Ajouter une option pour la converion netlist vers xdot
    opts.on("-s", "--show [PATH]", "Export the current Netlist to .dot format.") do |path|
        @options[:show] = true
        @args[:show] = path
        # ? : Voir si on ajoute un nom ou pas pour préciser l'entité à visualiser, sûrement plus pratique
        # ? : Voir même un titre à la figure pour pouvoir l'utiliser telle qu'elle ailleurs. 
    end

end.parse!

@obj = Netlist::Wrapper.new "tmp" # TODO : remplacer par le nom du fichier parsé dans le chemin, sinon "local" ou "tmp"

if @options[:version]
    # TODO : Exiting the program doing nothing more
elsif @options[:import]

    if @options[:imp_format]
        @obj.import(@args[:import][:file], @args[:import][:format])
    else 
        @obj.load_def @args[:import][:file]
    end

    if @options[:show]
        @obj.show @args[:show]
    end

    @obj.store_def "~.enl"

    if @options[:export]
        if @options[:exp_format] 
            @obj.export(@args[:export][:file], @args[:export][:format])
        else 
            @obj.store_def
        end
    end

elsif @options[:export]

    if File.exist?("~.enl")
        @obj.load_def "./~.enl"
    else
        raise "ERROR : No file precedently loaded currently available, please explicitly import a netlist."
    end

    if @options[:exp_format]
        @obj.export(@args[:export][:file], @args[:export][:format])
    else
        @obj.store_def @args[:export][:file]
    end

    if @options[:show]
        @obj.show @args[path]
    end

elsif @options[:show]

    if @args[:show].nil?
        if File.exist?("~.enl")
            @obj.load_def "./~.enl"
        else
            raise "ERROR : No file precedently loaded currently available, please explicitly import a netlist."
        end
    else 
        if File.exist? @args[:show]
            @obj.load_def @args[:show]
        else 
            raise "ERROR : No file precedently loaded currently available, please explicitly import a netlist."
        end
    end

    @obj.show @args[:show]

end
