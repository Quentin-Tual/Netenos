require_relative '../lib/vhdl'
require_relative '../lib/converter'
require_relative '../lib/netlist'

include Netlist
include VHDL

txt = IO.read('./tests/test.vhd')
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast

test = VHDL::AST::Work.new(decorated_ast.entity)
test.export

txt = IO.read('./tests/test2.vhd')
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))

visitor = VHDL::Visitor.new
visitor.visitAST ast
visitor.exportDecAst '.tmp'

converter = Converter::ConvVhdl2Netlist.new
converter.load '.tmp'
recovNetlist = converter.convAst

DotGen.new.dot recovNetlist

unconverter = Converter::ConvNetlist2Vhdl.new
rev_source_code = unconverter.get_timed_vhdl recovNetlist
puts rev_source_code
