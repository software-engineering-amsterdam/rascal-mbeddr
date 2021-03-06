module extensions::statemachine::typing::Indexer
extend core::typing::indexer::Indexer;

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
		d.name = id( name )[@message = error( indexError(), storeResult.errorMsg, d.name@location )]; 
	}
	
	storeResult = store( storeResult.table, symbolKey( name ),  stateMachine( name ),  scope,  true,  d@location ) ;
	d.body = indexer( body, storeResult.table, stateMachine( scope ) );
	
	d = hoistStateMachineIndextable( d );
	
	IndexTable symbols = size( d.body ) > 0 ? d.body[0]@indextable : ();
    symbols = store( symbols, symbolKey( "init" ),  \function( \void(), [] ),  scope,  true,  d@location ) .table;
	symbols = store( symbols, symbolKey( "isInState" ),  \function( \boolean(), [ state() ] ),  scope,  true,  d@location ) .table;
	symbols = store( symbols, symbolKey( "setState" ),  \function( \void(), [ state() ] ),  scope,  true,  d@location ) .table;
		
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
	storeResult = store( table, symbolKey(name),  \type,  scope,  true,  s@location ) ;
	s.init = indexWrapper( init, table, scope );
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:inEvent( id( name ), list[Param] params ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey( name ),  inEvent( params ),  scope,  true,  s@location ) ;
	
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:outEvent( id( name ), list[Param] params, Id ref ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey( name ),  outEvent( parameterTypes( params ) ),  scope,  true,  s@location ) ;
	
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ StateMachineStat astNode, IndexTable table, str errorMsg ]
indexer( StateMachineStat s:state( id( name ), list[StateStat] body ),
		 IndexTable table,
		 Scope scope
		) {
	storeResult = store( table, symbolKey( name ),  state(),  scope,  true,  s@location ) ;
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


