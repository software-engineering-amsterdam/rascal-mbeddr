module statemachine::\test::Helper

import statemachine::Syntax;
import statemachine::AST;
import statemachine::Desugar;

import statemachine::typing::Indexer;
import statemachine::typing::Constraints;
import statemachine::typing::Resolver;
import statemachine::typing::IndexTable;
import statemachine::typing::Scope;

extend statemachine::typing::resolver::Helper;
extend \test::Helper;
extend desugar::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module desugarModule( Module m ) {
	m = desugar_statemachine( m );
	m = runDesugar( m );
	
	return m;
}

