class Simulator

    def initialize inverted_netlist
        @inverted_netlist = inverted_netlist
        @tick = 0
    end

    def run nb_ticks = 100
        while @tick < nb_ticks
            step
            update_env
        end
    end

    def step
        @tick += 1
    end

    def update_env
        @inverted_netlist.update
    end

end