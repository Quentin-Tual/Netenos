
#! /usr/env/bin ruby    
require_relative "../lib/netenos.rb"
require_relative "../tests/test_lib.rb"


include Netlist

# Global circuit instanciation
global = Circuit.new("test_circ")
["i1","i2","i3"].each{|port_name| global << Port.new(port_name, :in)}
["o1", "o2"].each{|port_name| global << Port.new(port_name, :out)}

# ? Accepter des noms de composants identiques ? Normalement pas besoin
# Components instanciation
a1 = A.new("a1")
a2 = A.new("a2")
b1 = B.new("b1")
b2 = B.new("b2")
c1 = C.new("c1")

# Implement components to circuit
global << a1
global << a2
global << b1
global << b2
global << c1

# L'appartenance des ports des classes héritant de la classe Circuit doit être rafraîchie en dehors de la fonction d'initialisation (sinon pas prise en compte car objet pas encore instancié). On utilise la fontionc refresh. 
#global.port_refresh

# Instanciation des "fils" de classe Wire pour le branchement de plusieurs entrées sur la même sortie/entrée globale.
w1 = Wire.new("w1")
w1 <= a1.get_port_named("o1")
b1.get_port_named("i1") <= w1
a2.get_port_named("i1") <= w1
c1.get_port_named("i1") <= w1

w2 = Wire.new("w2")
w2 <= b1.get_port_named("o1")
a2.get_port_named("i2") <= w2
b2.get_port_named("i2") <= w2

w3 = Wire.new("w3")
w3 <= a2.get_port_named("o1")
b2.get_port_named("i1") <= w3
c1.get_port_named("i2") <= w3


# Link ports between components
c1.get_port_named("i3") <= b2.get_port_named("o1") 

# Link ports to global/main circuit IOs
a1.get_port_named("i1") <= global.get_port_named("i1") 
a1.get_port_named("i2") <= global.get_port_named("i2")
b1.get_port_named("i2") <= global.get_port_named("i3")
global.get_port_named("o1") <= c1.get_port_named("o1") 
global.get_port_named("o2") <= c1.get_port_named("o2")

# pp global.name

viewer = Converter::DotGen.new
viewer.dot global

# Insert an HT using Tamperer
modifier = Inserter::Tamperer.new(global)
modifier.select_ht("cotd_s38417")
modified = modifier.insert 
modifier = nil

viewer.dot(modified, 'test_circ_mod.dot')