module statemachine::typing::Indexer
extend typing::Indexer;

import statemachine::AST;

import statemachine::typing::IndexTable;
import statemachine::typing::Scope;

map[ str, Type ] stateMachineFunctions = ( "init" : \function( \void(), [] ) );

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:stateMachine( list[Modifier] mods, id( name ), list[Id] initial, list[StateMachineStat] body ),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {
	storeResult = store( tables, <name,typedef()>, < stateMachine( name ), scope, true > );
	
	if( storeResult.errorMsg != "" ) {
		d.name = id( name )[@message = error( storeResult.errorMsg, d.name@location )]; 
	}
	
	storeResult = store( storeResult.tables, name, < stateMachine( name ), scope, true > );
	d.body = indexer( body, storeResult.tables, stateMachine( scope ) );
	
	d = hoistStateMachineIndexTables( d );
	
	symbols = size( d.body ) > 0 ? d.body[0]@symboltable : ();
    symbols["init"] = symbolRow( \function( \void(), [] ), scope, true );
	symbols["isInState"] = symbolRow( \function( \boolean(), [ state() ] ), scope, true );
	symbols["setState"] = symbolRow( \function( \void(), [ state() ] ), scope, true );
		
	storeResult.tables.symbols = update( storeResult.tables.symbols, name, symbolRow( symbols, stateMachine( name ), scope, true ) );
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

Decl hoistStateMachineIndexTables( Decl d:stateMachine( _, _, _, _ ) ) {
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
	
	return d;
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
indexer( StateMachineStat s:inEvent( id( name ), list[Param] params ),
		 IndexTables tables,
		 Scope scope
		) {
	storeResult = store( tables, name, < inEvent( params ), scope, true > );
	
	return < s[@scope=scope], storeResult.tables, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTables tables, str errorMsg ]
indexer( StateMachineStat s:outEvent( id( name ), list[Param] params, Id ref ),
		 IndexTables tables,
		 Scope scope
		) {
	storeResult = store( tables, name, < outEvent( parameterTypes( params ) ), scope, true > );
	
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
	if( event.name in tables.symbols && inEvent( list[Param] params ) := tables.symbols[ event.name ].\type ) {
		result = indexParams( params, tables, function( scope ) );
		tables = result.tables;
	}	
	
	s.cond = indexer( cond, tables, function( scope ) );
	return < s[@scope=scope], tables, "" >;	
}

tuple[ StateStat astNode, IndexTables tables, str errorMsg ]
indexer( StateStat s:on( Id event, list[Expr] cond, Id next, list[Stat] body ),
		 IndexTables tables,
		 Scope scope
		) {
	if( event.name in tables.symbols && inEvent( list[Param] params ) := tables.symbols[ event.name ].\type ) {
		result = indexParams( params, tables, function( scope ) );
		tables = result.tables;
	}	
	
	s.cond = indexer( cond, tables, function( scope ) );
	s.body = indexer( body, tables, function( scope ) );
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

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:send( _, list[Expr] args ),
		 IndexTables tables,
		 Scope scope
		) {
	s.args = indexer( args, tables, scope );
	return < s[@scope=scope], tables, "" >;	
}


