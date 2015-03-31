module Desugar

import util::ext::Node;

extend extensions::baseextensions::Desugar;
extend extensions::unittest::Desugar;
extend extensions::statemachine::Desugar;

extend core::desugar::Runner;

Module desugarModule( Module m ) {
	
	ast = desugarBaseExtensions( m );
	ast = desugarUnitTest( ast );
	ast = desugarStateMachine( ast );
	
	ast = runDesugar( ast );

	return ast;
}