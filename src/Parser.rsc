module Parser

import ParseTree;

extend extensions::baseextensions::AST;
extend extensions::baseextensions::Syntax;

extend extensions::unittest::AST;
extend extensions::unittest::Syntax;

extend extensions::statemachine::AST;
extend extensions::statemachine::Syntax;

Module createAST( Tree pt ) = implode( #Module, pt );
Module createAST( loc location ) = implode( #Module, parse( location ) );

Tree parse( str src, loc location ) = parse( #start[Module], src, location );
Tree parse( loc location ) = parse( #start[Module], location );
