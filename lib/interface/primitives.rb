module Interface

    def work_in_progress
        raise ("WIP")
    end

    # Generate a netlist
    def gen_netlist(name, *params)
        work_in_progress
    end

    # Import a .blif netlist
    def import_blif(filename)
        work_in_progress
    end

    # Insert a HT in a given netlist
    def insert_ht(filename, ht_type)
        work_in_progress
    end

    # Generate .vhd file for a given .enl file
    def gen_vhdl(filename)
        work_in_progress
    end

    # Generate gtech repertory
    def gen_gtech(gtech_type)
        work_in_progress
    end 

    # Generate a test sequence with the given method for a given .enl file
    def gen_stimfile(filename, stim_type)
        work_in_progress
    end

    # Generate comparative simulation files for given init and altered .enl files and a given stimfile (assuming respective .vhd files and gtech repertory  are already created)
    #   - testbenchs
    #   - compile.sh
    def gen_simfiles(init_filename, alt_filename, stim_file)
        work_in_progress
    end

    # Run a generated simulation 
    def run_sim
        work_in_progress 
    end

end