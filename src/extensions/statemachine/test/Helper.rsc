module extensions::statemachine::\test::Helper

import extensions::statemachine::Syntax;
import extensions::statemachine::AST;
import extensions::statemachine::Desugar;

import extensions::statemachine::typing::Indexer;
import extensions::statemachine::typing::Constraints;
import extensions::statemachine::typing::Resolver;
import extensions::statemachine::typing::IndexTable;
import extensions::statemachine::typing::Scope;

extend \test::Helper;
extend core::desugar::Runner;
extend typechecker::indexer::Runner;
extend typechecker::resolver::Runner;

extend typechecker::constraints::Runner;

Module desugarModule( Module m ) {
	m = desugarStateMachine( m );
	m = runDesugar( m );
	
	return m;
}

