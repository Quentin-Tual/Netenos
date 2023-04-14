#! usr/bin/ruby

require 'optparse'
require_relative "../lib/netlist.rb"
require_relative "../lib/interface.rb"

# TESTS : 
require_relative "../tests/test_lib.rb"

$DEF_TEMP_PATH = "/tmp/enoslist/"

Dir.mkdir($DEF_TEMP_PATH) unless File.exists?($DEF_TEMP_PATH)

@options = {}
@args = {}

ARGV << '-h' if ARGV.empty?

OptionParser.new do |opts|

# TODO 1 : Tester si les derniers ajouts fonctionnent tous correctement.
# TODO 2 : rendre l'aide (banner) plus claire pour l'utilisateur avec un exemple ou deux.
# TODO 3 : Prévoir des affichages pour l'option de verbosité lorsque possible
# TODO 4 : Placer le fichier temporaire ~.enl dans /tmp (plus propre et transparent), problème de droit d'accès ?


    Version = "Enoslist 0.1.0b (Apr 2023)"

    opts.on("-v", "--verbose", "Show extra information.") do
        @options[:verbose] = true
    end

    opts.on("-V", "--version", "Show used program current version.") do
        @options[:version] = true
        puts Version
    end

    opts.on("-i FILE", "--import FILE", "Import a Netlist from one file in a specified format.") do |passed_args|
        @options[:import] = true
        @args[:import] = {:file => passed_args}
        # * : Vérification d'une éventuelle commande courte précédente, complétion des informations manquantes.
        if @options[:export] and not(@options[:exp_format])
            @options[:exp_format] = true
            @args[:export][:format] = "def"
        end
    end

    opts.on("-e FILE", "--export FILE","Export a Netlist to a specified format (-f option) in a file with the given name.") do |passed_args|
        @options[:export] = true
        @args[:export] = {:file => passed_args}
        
        if @options[:import] and not(@options[:imp_format])
            @options[:imp_format] = true
            @args[:import][:format] = "def"
        end
    end

    # ? : Optimisation possible en supprimant le format s'il vaut 'def' ? Potentiellement intéressant.
    opts.on("-f FORMAT", "--format FORMAT", ['json','dot','vhdl','def'], "Allow to specify format for import and export.") do |format|
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

    opts.on("-s", "--show [PATH]", "Export the current Netlist to .dot format.") do |path|
        @options[:show] = true
        @args[:show] = path
        # ? : Voir si on ajoute un nom ou pas pour préciser l'entité à visualiser, sûrement plus pratique
    end

    opts.on("-g [NAME, GATE_NUMBER, INPUT_NUMBER, OUTPUT_NUMBER, STAGE_NUMBER]", "--randgen [NAME, GATE_NUMBER, INPUT_NUMBER, OUTPUT_NUMBER, STAGE_NUMBER]", Array, "Generates a random netlist according to parameters given in arguments (default: rand_circ,10,10,5,5).") do |randgen_args|
        @options[:randgen] = true
        @args[:randgen] = randgen_args
    end

    opts.on("-t [HT_TYPE, TRIG_SIG_NUMBER]", "--tamper [HT_TYPE, TRIG_SIG_NUMBER]", Array, "Inserts a Hardware Trojan of the given structure (HT_TYPE and TRIG_SIG_NUMBER) in the imported or current registered netlist (default : xor_and,4).") do |tamper_param| 
        @options[:tamper] = true
        @args[:tamper] = tamper_param
    end

# puts options.inspect
end.parse!

@obj = Netlist::Wrapper.new

if @options[:verbose]
    puts "Request registered :"
    @options.keys.each do |option|
        if @args[option].nil?
            puts "\t- #{option.to_s}" 
        else
            puts "\t- #{option.to_s} : #{@args[option]}" 
        end 
    end
end

if @options[:randgen]

    if @options[:verbose]
        puts "Random netlist generation, then saved at \"#{$DEF_TEMP_PATH}~.enl\"."
    end
    informations = @obj.randgen @args[:randgen]
    if @options[:verbose]
        puts "Generated netlist informations  : "
        puts "\t- Inputs number : #{informations[0]}"
        puts "\t- Outputs number : #{informations[1]}"
        puts "\t- Components number : #{informations[2]}"
        puts "\t- Netlist critical path : #{informations[3]}"
    end
    @obj.store_def "#{$DEF_TEMP_PATH}~.enl"
end

if @options[:version]
    # * : Exiting the program doing nothing more
elsif @options[:import]

    if @options[:verbose]
        print "Import of #{@args[:import][:file]}"
    end

    if @options[:imp_format]
        if @options[:verbose]
            puts " in #{@args[:import][:format]} format."
        end
        @obj.import(@args[:import][:file], @args[:import][:format])
    else 
        if @options[:verbose]
            puts " in default format."
        end
        @obj.load_def @args[:import][:file]
    end

    if @options[:tamper]
        if @options[:verbose]
            puts "Tampering of the imported file, using : \n\t- HT type : #{@args[:tamper][0]}\n\t- Number of trigger signals : #{@args[:tamper][1]}" 
        end
        if @args[:tamper][1].nil?
        
            @obj.tamper @args[:tamper][0], nil
        else
            @obj.tamper @args[:tamper][0], @args[:tamper][1].to_i
        end
    end

    # if @options[:show]
    #     @obj.show @args[:show]
    # end
    if @options[:verbose]
        puts "Saving the current netlist in default format at #{$DEF_TEMP_PATH}~.enl" 
    end
    @obj.store_def "#{$DEF_TEMP_PATH}~.enl"

    if @options[:export]
        if @options[:verbose]
            print "Exporting netlist " 
        end
        if @options[:exp_format] 
            if @options[:verbose]
                puts "in #{@args[:export][:format]} format at #{$DEF_TEMP_PATH}~.enl"
            end
            @obj.export(@args[:export][:file], @args[:export][:format])
        else 
            if @options[:verbose]
                puts "in default format at #{$DEF_TEMP_PATH}~.enl"
            end
            @obj.store_def
        end
    end

elsif @options[:export]
    
    if File.exist?("#{$DEF_TEMP_PATH}~.enl")
        @obj.load_def "#{$DEF_TEMP_PATH}~.enl"
    else
        raise "ERROR : No file precedently loaded currently available, please explicitly import a netlist."
    end

    if @options[:verbose]
        print "Exporting netlist #{@obj.get_name} at #{@args[:export][:file]} "
    end

    if @options[:exp_format]
        if @options[:verbose]
            puts "in #{@args[:export][:format]} format."
        end
        @obj.export(@args[:export][:file], @args[:export][:format])
    else
        if @options[:verbose]
            puts "in default format."
        end
        @obj.store_def @args[:export][:file]
    end

    # if @options[:show]
    #     @obj.show @args[path]
    # end

elsif @options[:tamper]
    if @obj.netlist.nil?
        @obj.load_def "#{$DEF_TEMP_PATH}~.enl"
    end
    if @options[:verbose]
        puts "Tampering of netlist #{@obj.get_name}, using : \n\t- HT type : #{@args[:tamper][0]}\n\t- Number of trigger signals : #{@args[:tamper][1]}" 
    end
    if @args[:tamper][1].nil?
        
        @obj.tamper @args[:tamper][0], nil
    else
        @obj.tamper @args[:tamper][0], @args[:tamper][1].to_i
    end
    @obj.store_def "#{$DEF_TEMP_PATH}~.enl"
end 

if @options[:show]

    if @args[:show].nil?
        if File.exist?("#{$DEF_TEMP_PATH}~.enl")
            @obj.load_def "#{$DEF_TEMP_PATH}~.enl"
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

    if @options[:verbose]
        puts "Openning netlist #{@obj.get_name} graph visualization (xdot)." 
    end
    @obj.show @args[:show]

end
