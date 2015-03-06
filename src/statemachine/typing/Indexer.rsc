module statemachine::typing::Indexer
extend typing::Indexer;

import statemachine::AST;

import statemachine::typing::IndexTable;
import statemachine::typing::Scope;

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:stateMachine( list[Modifier] mods, id( name ), list[Id] initial, list[StateMachineStat] body ),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {

	storeResult = store( tables, name, < stateMachine(), scope, true > );
	d.body = indexer( body, storeResult.tables, stateMachine( scope ) );
	
	if( size( d.body ) > 0 ) {
		symbols = d.body[-1]@symboltable;
		types = d.body[-1]@typetable;
		
		tables = <symbols,types>;
		
		d.body = for( s <- d.body ) {
			s@symboltable = symbols;
			s@typetable = types;
		
			s = visit( s ) {
				case &T <: node n : {
					if( "symboltable" in getAnnotations(n) ) {
						n@symboltable = n@symboltable + symbols;
						n@typetable = n@typetable + types;
						insert n;
					}
				}
			}
			
			append s;
		} 
	}
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ StateMachineStat astNode, IndexTables tables, str errorMsg ]
indexer( StateMachineStat s:var( list[Modifier] mods, Type \type, id( name ), Expr init ),
		 IndexTables tables,
		 Scope scope
		) {
	storeResult = store( tables, name, < \type, scope, true > );
	s.init = indexWrapper( init, tables, scope );
	return < s[@scope=scope], storeResult.tables, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTables tables, str errorMsg ]
indexer( StateMachineStat s:state( id( name ), list[StateStat] body ),
		 IndexTables tables,
		 Scope scope
		) {
	storeResult = store( tables, name, < state(), scope, true > );
	s.body = indexer( body, tables, scope );
	return < s[@scope=scope], storeResult.tables, storeResult.errorMsg >;	
}

tuple[ StateStat astNode, IndexTables tables, str errorMsg ]
indexer( StateStat s:on( Id event, list[Expr] cond, Id next ),
		 IndexTables tables,
		 Scope scope
		) {
	s.cond = indexer( cond, tables, scope );
	return < s[@scope=scope], tables, "" >;	
}

tuple[ StateStat astNode, IndexTables tables, str errorMsg ]
indexer( StateStat s:entry( list[Stat] body ),
		 IndexTables tables,
		 Scope scope
		) {
	s.body = indexer( body, tables, scope );
	return < s[@scope=scope], tables, "" >;	
}

tuple[ StateStat astNode, IndexTables tables, str errorMsg ]
indexer( StateStat s:exit( list[Stat] body ),
		 IndexTables tables,
		 Scope scope
		) {
	s.body = indexer( body, tables, scope );
	return < s[@scope=scope], tables, "" >;	
}


