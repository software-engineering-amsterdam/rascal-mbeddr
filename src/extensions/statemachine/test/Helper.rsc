module extensions::statemachine::\test::Helper

import extensions::statemachine::Syntax;
import extensions::statemachine::AST;
import extensions::statemachine::Desugar;

import extensions::statemachine::typing::Indexer;
import extensions::statemachine::typing::Constraints;
import extensions::statemachine::typing::Resolver;
import extensions::statemachine::typing::IndexTable;
import extensions::statemachine::typing::Scope;

extend extensions::statemachine::typing::resolver::Helper;
extend \test::Helper;
extend desugar::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module desugarModule( Module m ) {
	m = desugarStateMachine( m );
	m = runDesugar( m );
	
	return m;
}

