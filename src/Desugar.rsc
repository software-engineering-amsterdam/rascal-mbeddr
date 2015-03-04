module Desugar

extend baseextensions::Desugar;
extend unittest::Desugar;

Module desugarModule( Module m ) {
	solve (m) {
	  m = visit( m ) {
		case Stat s => desugar( s )
		case Expr e => desugar( e )
		case Decl d => desugar( d )
	  }
	}
}


