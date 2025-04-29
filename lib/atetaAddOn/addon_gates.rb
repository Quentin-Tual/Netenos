module Netlist
    class And2 
        PROPAG_TIME = {:one => 1, :int_multi => 3}
        SMT_NAME = "and"
    end

    class Or2
        PROPAG_TIME = {:one => 1, :int_multi => 3}
        SMT_NAME = "or"
    end

    class Nand2
        PROPAG_TIME = {:one => 1, :int_multi => 4}
    end      

    class Nor2
        PROPAG_TIME = {:one => 1, :int_multi => 4}
    end

    class Xor2
        PROPAG_TIME = {:one => 1, :int_multi => 5}
        SMT_NAME = "xor"
    end

    class Not 
        PROPAG_TIME = {:one => 1, :int_multi => 2}
        SMT_NAME = "not"
    end 

    class Buffer 
        PROPAG_TIME = {:one => 1, :int_multi => 2}
    end 
end