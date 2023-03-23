require_relative "../lib/vhdl.rb"
require_relative "../lib/netlist.rb"

# TODO : Voir pour faire des tests avec Rspec

include Netlist
include VHDL

txt=IO.read("./tests/test.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast
# pp decorated_ast

test = VHDL::AST::Work.new(decorated_ast.entity)
# # pp test
test.export

txt = IO.read("./tests/test2.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))

visitor = VHDL::Visitor.new
decorated_ast = visitor.visitAST ast
visitor.exportDecAst ".tmp"

converter = Netlist::ConvVhdl.new
converter.load ".tmp"
recovNetlist = converter.convAst

DotGen.new.dot recovNetlist