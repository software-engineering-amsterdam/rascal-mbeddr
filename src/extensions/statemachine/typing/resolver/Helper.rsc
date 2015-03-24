module extensions::statemachine::typing::resolver::Helper
extend typing::resolver::Helper;

Module resolver( m:\module( name, imports, decls ) ) = resolver( m, () );
Module resolver( &T <: node n, IndexTable table ) {
	n = copyDownIndexTables( n, table );

	n = visit( n ) {
		case Stat s => resolve( s ) 
		case Expr e => resolve( e )
		case Decl d => resolve( d )
		case StateMachineStat s => resolve( s )
		case StateStat s => resolve( s ) 
	}

	return n;	
}
