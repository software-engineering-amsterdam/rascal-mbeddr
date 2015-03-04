module Parser

import ParseTree;

extend baseextensions::AST;
extend baseextensions::Syntax;

extend unittest::AST;
extend unittest::Syntax;

extend statemachine::AST;
extend statemachine::Syntax;

Module createAST( Tree pt ) = implode( #Module, pt );
Module createAST( loc location ) = implode( #Module, parse( location ) );

Tree parse( str src, loc location ) = parse( #start[Module], src, location );
Tree parse( loc location ) = parse( #start[Module], location );
