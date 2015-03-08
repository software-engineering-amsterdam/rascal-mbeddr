module Desugar

extend baseextensions::Desugar;
extend unittest::Desugar;
extend statemachine::Desugar;

Module desugarModule( Module m ) {
	ast = desugar_unittest( m );
	ast = desugar_baseextensions( m );
	ast = desugar_statemachine( m );
	
	solve (m) {
	  m = visit( m ) {
		case Stat s => desugar( s )
		case Expr e => desugar( e )
		case Decl d => desugar( d )
	  }
	}
	
	return m;
}


