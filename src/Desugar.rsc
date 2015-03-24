module Desugar

extend extensions::baseextensions::Desugar;
extend extensions::unittest::Desugar;
extend extensions::statemachine::Desugar;

extend desugar::Helper;

Module desugarModule( Module m ) {
	
	ast = desugar_unittest( m );
	ast = desugar_statemachine( ast );
	ast = desugarBaseExtensions( ast );

	ast = runDesugar( ast );
	
	return ast;
}