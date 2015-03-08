module baseextensions::typing::Indexer
extend typing::Indexer;

import baseextensions::AST;

// ======= //
// INDEXER //
// ======= //

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:lambda(list[Param] params, list[Stat] body ), IndexTables tables, Scope scope ) {
	scope = function(scope);
	
	result = indexParams( params, tables, scope );
	e.params = result.params;
	e.body = indexer( body, result.tables, scope); 

	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:lambda(list[Param] params, Expr body ), IndexTables tables, Scope scope ) {
	scope = function(scope);
	result = indexParams( params, tables, scope );
	
	body@symboltable=result.tables.symbols;
	body@typetable=result.tables.types;
	e.params = result.params;
	e.expr = indexWrapper( body, result.tables, scope );
	
	return < e[@scope = scope], tables, "" >;	
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:constant( id( name ), Literal \value), IndexTables tables, Scope scope ) {
	value_type = getLiteralType( \value );
	storeResult = store( tables, name, <value_type,scope,true> );

	return < d, storeResult.tables, storeResult.errorMsg >;	
}

private Type getLiteralType( hex(_) ) = int32();
private Type getLiteralType( \int(_) ) = int32();
private Type getLiteralType( char(_) ) = char();
private Type getLiteralType( float(_) ) = float();
private Type getLiteralType( string(_) ) = pointer( char() );