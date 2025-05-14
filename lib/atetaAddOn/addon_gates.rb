module Netlist
    class And2 
        PROPAG_TIME = {:one => 1, :int_multi => 3}
        SMT_EXPR  = ["(and",")"]
    end

    class Or2
        PROPAG_TIME = {:one => 1, :int_multi => 3}
        SMT_EXPR  = ["(or",")"]
    end

    class Nand2
        PROPAG_TIME = {:one => 1, :int_multi => 4}
        SMT_EXPR  = ["(not (and","))"]
    end      

    class Nor2
        PROPAG_TIME = {:one => 1, :int_multi => 4}
        SMT_EXPR  = ["(not (or","))"]
    end

    class Xor2
        PROPAG_TIME = {:one => 1, :int_multi => 5}
        SMT_EXPR  = ["(xor",")"]
    end

    class Not 
        PROPAG_TIME = {:one => 1, :int_multi => 2}
        SMT_EXPR  = ["(not",")"]
    end 

    class Buffer 
        PROPAG_TIME = {:one => 1, :int_multi => 2}
        SMT_EXPR  = ["",""]
    end 
end