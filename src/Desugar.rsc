module Desugar

extend baseextensions::Desugar;
extend unittest::Desugar;
extend statemachine::Desugar;

Module desugarModule( Module m ) {
	
	ast = desugar_unittest( m );
	ast = desugar_statemachine( ast );
	
	ast = desugar_baseextensions( ast );
	
	solve (ast) {
	  ast = visit( ast ) {
		case &T <: node n => desugar( n )
	  }
	}
	
	return ast;
}


