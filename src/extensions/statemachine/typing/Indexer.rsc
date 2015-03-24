module extensions::statemachine::typing::Indexer
extend typing::indexer::Indexer;

import extensions::statemachine::AST;

import extensions::statemachine::typing::IndexTable;
import extensions::statemachine::typing::Scope;

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:stateMachine( list[Modifier] mods, id( name ), list[Id] initial, list[StateMachineStat] body ),
	   	 IndexTable table, 
	   	 Scope scope
	   ) {
	storeResult = store( table, typeKey(name,typedef()), typeRow( stateMachine( name ), scope, true ) );
	
	if( storeResult.errorMsg != "" ) {
		d.name = id( name )[@message = error( storeResult.errorMsg, d.name@location )]; 
	}
	
	storeResult = store( storeResult.table, symbolKey( name ), symbolRow( stateMachine( name ), scope, true ) );
	d.body = indexer( body, storeResult.table, stateMachine( scope ) );
	
	d = hoistStateMachineIndextable( d );
	
	IndexTable symbols = size( d.body ) > 0 ? d.body[0]@indextable : ();
    symbols = store( symbols, symbolKey( "init" ), symbolRow( \function( \void(), [] ), scope, true ) ).table;
	symbols = store( symbols, symbolKey( "isInState" ), symbolRow( \function( \boolean(), [ state() ] ), scope, true ) ).table;
	symbols = store( symbols, symbolKey( "setState" ), symbolRow( \function( \void(), [ state() ] ), scope, true ) ).table;
		
	storeResult.table = store( storeResult.table, objectKey( name ), objectRow( symbols ) ).table; 
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

Decl hoistStateMachineIndextable( Decl d:stateMachine( _, _, _, _ ) ) {
	if( size( d.body ) > 0 ) {
		table = d.body[-1]@indextable;
		
		d.body = [ hoistStateMachineStat( s, table ) | s <- d.body ]; 
	}
	
	return d;
}

private StateMachineStat hoistStateMachineStat( StateMachineStat s, IndexTable table ) {
	s@indextable = table;

	s = visit( s ) {
		case &T <: node n => hoistNode( n, table ) 
	}
	
	return s;
}

private &T <: node hoistNode( &T <: node n, IndexTable table ) {
	if( "indextable" in getAnnotations(n) ) {
		n@indextable = n@indextable + table;
	}
	
	return n;
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:var( list[Modifier] mods, Type \type, id( name ), Expr init ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey(name), symbolRow( \type, scope, true ) );
	s.init = indexWrapper( init, table, scope );
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:inEvent( id( name ), list[Param] params ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey( name ), symbolRow( inEvent( params ), scope, true ) );
	
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:outEvent( id( name ), list[Param] params, Id ref ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey( name ), symbolRow( outEvent( parameterTypes( params ) ), scope, true ) );
	
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:state( id( name ), list[StateStat] body ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey( name ), symbolRow( state(), scope, true ) );
	s.body = indexer( body, table, scope );
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateStat astNode, IndexTable table, str errorMsg ]
indexer( StateStat s:on( Id event, list[Expr] cond, Id next ),
		 IndexTable table,
		 Scope scope
		) {
	if( contains( table, symbolKey(event.name) ) && inEvent( list[Param] params ) := lookup( table, symbolKey(event.name) ).\type ) {
		result = indexParams( params, table, function( scope ) );
		table = result.table;
	}	
	
	s.cond = indexer( cond, table, function( scope ) );
	return < s[@scope=scope], table, "" >;	
}

tuple[ StateStat astNode, IndexTable table, str errorMsg ]
indexer( StateStat s:on( Id event, list[Expr] cond, Id next, list[Stat] body ),
		 IndexTable table,
		 Scope scope
		) {
	if( contains( table, symbolKey(event.name) ) && inEvent( list[Param] params ) := lookup( table, symbolKey(event.name) ).\type ) {
		result = indexParams( params, table, function( scope ) );
		table = result.table;
	}	
	
	s.cond = indexer( cond, table, function( scope ) );
	s.body = indexer( body, table, function( scope ) );
	return < s[@scope=scope], table, "" >;	
}

tuple[ StateStat astNode, IndexTable table, str errorMsg ]
indexer( StateStat s:entry( list[Stat] body ),
		 IndexTable table,
		 Scope scope
		) {
	s.body = indexer( body, table, scope );
	return < s[@scope=scope], table, "" >;	
}

tuple[ StateStat astNode, IndexTable table, str errorMsg ]
indexer( StateStat s:exit( list[Stat] body ),
		 IndexTable table,
		 Scope scope
		) {
	s.body = indexer( body, table, scope );
	return < s[@scope=scope], table, "" >;	
}

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:send( _, list[Expr] args ),
		 IndexTable table,
		 Scope scope
		) {
	s.args = indexer( args, table, scope );
	return < s[@scope=scope], table, "" >;	
}


