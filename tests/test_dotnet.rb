#! /usr/env/bin ruby    

require_relative "../lib/netlist.rb"
require 'json' 


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
w1 = Wire.new(a1.get_port_named("o1"), b1.get_port_named("i1"), a2.get_port_named("i1"),c1.get_port_named("i1"))
w2 = Wire.new(b1.get_port_named("o1"), a2.get_port_named("i2"), b2.get_port_named("i2"))
w3 = Wire.new(a2.get_port_named("o1"), b2.get_port_named("i1"), c1.get_port_named("i2"))

# Link ports between components
b2.get_port_named("o1") <= c1.get_port_named("i3")

# Link ports to global/main circuit IOs
global.get_port_named("i1") <= a1.get_port_named("i1")
global.get_port_named("i2") <= a1.get_port_named("i2") 
global.get_port_named("i3") <= b1.get_port_named("i2")
c1.get_port_named("o1") <= global.get_port_named("o1")
c1.get_port_named("o2") <= global.get_port_named("o2")

# pp global.name

viewer = DotGen.new
viewer.dot global

netson = Netson.new
netson.save_as_json(global)

import_test = netson.load("./test_circ.json")

viewer.dot(import_test)