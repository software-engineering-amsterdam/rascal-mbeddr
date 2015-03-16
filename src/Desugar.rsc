module Desugar

extend baseextensions::Desugar;
extend unittest::Desugar;
extend statemachine::Desugar;

extend desugar::Helper;

Module desugarModule( Module m ) {
	
	ast = desugar_unittest( m );
	ast = desugar_statemachine( ast );
	ast = desugar_baseextensions( ast );

	ast = runDesugar( ast );
	
	return ast;
}