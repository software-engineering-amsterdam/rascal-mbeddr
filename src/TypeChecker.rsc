module TypeChecker

import lang::mbeddr::AST;

extend baseextensions::TypeChecker;
extend unittest::TypeChecker;
extend statemachine::TypeChecker;

Module runTypeChecker( Module m ) { 
	m = createIndexTable( m );
	m = constraints( m );
	m = evaluator( m );
	return m;
}

// INDEXER //
Module createIndexTable( m:\module( name, imports, decls ) ) {
	m.decls = indexer( decls, <(), ()>, global() );
	return m;
}

// EVALUATOR //
Module evaluator( m:\module( name, imports, decls ) ) = evaluator( m, (), () );
Module evaluator( &T <: node n, SymbolTable symbols, TypeTable types ) {
	n = copyDownIndexTables( n, symbols, types );

	n = visit( n ) {

		case Expr e => evaluate( e )
		
		case Decl d => evaluate( d )
		
		case Stat s => evaluate( s )
				
	}

	return n;	
}

Module copyDownIndexTables( Module m, SymbolTable symbols, TypeTable types ) {
	return top-down visit( m ) {
		case node n : {
			annos = getAnnotations( n );

			if( "symboltable" in annos ) {
				symbols = n@symboltable;
			} else {
				n = n[@symboltable = symbols];
			}
			
			if( "typetable" in annos ) {
				types = n@typetable;
			} else {
				n = n[@typetable = types];
			}
			
			insert n;
		}
	}
}

// CONSTRAINTS
Module constraints( Module m ) {
	return visit( m ) {
		case &T <: node n => constraint( n )
	}
}
