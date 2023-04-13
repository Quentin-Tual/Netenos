require_relative "../lib/vhdl.rb"
require_relative "../lib/converter.rb"
require_relative "../lib/netlist.rb"

include Netlist
include VHDL

txt=IO.read("./tests/test.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast

test = VHDL::AST::Work.new(decorated_ast.entity)
test.export

txt = IO.read("./tests/test2.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))

visitor = VHDL::Visitor.new
decorated_ast = visitor.visitAST ast
visitor.exportDecAst ".tmp"

converter = Netlist::ConvVhdl2Netlist.new
converter.load ".tmp"
recovNetlist = converter.convAst

DotGen.new.dot recovNetlist

unconverter = Netlist::ConvNetlist2Vhdl.new
rev_source_code = unconverter.get_vhdl recovNetlist
puts rev_source_code

