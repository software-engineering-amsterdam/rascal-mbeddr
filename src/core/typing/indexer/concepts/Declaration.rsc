module core::typing::indexer::concepts::Declaration
extend core::typing::indexer::Base;

// DECLARATIONS

tuple[ list[Param] params, IndexTable table ] indexParams(list[Param] params, IndexTable table, Scope scope ) {
	params = indexer( params, table, scope );
	table = size( params ) > 0 ? params[-1]@indextable : table;
		
	return < params, table >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats),
		 IndexTable table, 
		 Scope scope ) {
	storeResult = store( table, symbolKey(name),  \function( \type, parameterTypes( params ) ),  scope,  true,  d@location ) ;
	
	result = indexParams( params, storeResult.table, function( scope ) );
	
	d.stats = indexer( stats, result.table, function( scope ) );
	d.params = result.params;
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:function(list[Modifier] mods, Type \type, id( name ), list[Param] params),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey(name),  \function( \type, parameterTypes( params ) ),  scope,  false,  d@location ) ;
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:variable(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey(name),  \type,  scope,  false,  d@location ) ;
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:variable(list[Modifier] mods, Type \type, id( name ), Expr init),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey(name),  \type,  scope,  true,  d@location ) ;
	d.init = indexWrapper( init, storeResult.table, scope );
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

// TYPE DEFINITIONS

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl t:typeDef(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeKey(name,typedef()), typeRow( \type, scope, true ) );
	
	return < t[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl s:struct(list[Modifier] mods, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeKey(name,struct()), typeRow( struct( [] ), scope, false ) );
	
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl s:struct(list[Modifier] mods, id( name ), list[Field] fields),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeKey(name,struct()), typeRow( struct( fields ), scope, true ) );
	s.fields = indexer( fields, table, block( scope ) );
	
	return < s[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl e:enum(list[Modifier] mods, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeKey(name,enum()), typeRow( enum( [] ), scope, false ) );
	
	return < e[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl e:enum(list[Modifier] mods, id( name ), list[Enum] enums),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeKey(name,enum()), typeRow( enum( enums ), scope, false ) );
	
	e.enums = indexer( enums, table, block( scope ) );
	
	return < e[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl u:union(list[Modifier] mods, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeKey(name,union()), typeRow( union( [] ), scope, false ) );
	
	return < u[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl u:union(list[Modifier] mods, id( name ), list[Field] fields),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, typeRow( name,union() ), typeKey( union( fields ), scope, true ) );
	u.fields = indexer( fields, table, block( scope ) );
	
	
	return < u[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

// Fields

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl f:field( Type \type, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ),  \type,  scope,  true,  f@location ) ;
	
	return < f[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl c:const( id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ),  \void(),  scope,  true,  c@location ) ;
	
	return < c[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl c:const( id( name ), _ ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ),  \void(),  scope,  true,  c@location ) ;
	
	return < c[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:constant( id( name ), Expr init ), IndexTable table, Scope scope ) {
	visit( init ) {
		case var(id(_)) : { 
			d.init@message = error( staticEvaluationError(), "global constants must be statically evaluatable", d.init@location );
			return <d,table,"">; 
		}
	}
	
	init = visit( init ) {
		case Expr e => resolve( e )
	}
	initType = getType( init );
	
	if( isEmpty() := initType ) { d@message = error( "unable to statically resolve global constant\'s type", d@location ); }
	
	storeResult = store( table, symbolKey( name ), initType, scope, true, d@location, constant=true );

	return < d, storeResult.table, storeResult.errorMsg >;	
}

tuple[ Param astNode, IndexTable table, str errorMsg ]
indexer( Param p:param(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ),  \type,  scope,  true,  p@location ) ;

	return < p[@scope=scope], storeResult.table, storeResult.errorMsg >;
}
