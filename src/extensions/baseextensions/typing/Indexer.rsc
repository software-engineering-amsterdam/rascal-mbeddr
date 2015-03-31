module extensions::baseextensions::typing::Indexer
extend core::typing::indexer::Indexer;

import extensions::baseextensions::typing::Scope;
import extensions::baseextensions::AST;

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:lambda(list[Param] params, list[Stat] body ), IndexTable table, Scope scope ) {
	scope = function(scope);
	
	result = indexParams( params, table, scope );
	e.params = result.params;
	e.body = indexer( body, result.table, scope); 

	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:lambda(list[Param] params, Expr body ), IndexTable table, Scope scope ) {
	scope = function(scope);
	result = indexParams( params, table, scope );
	
	body@indextable = result.table;
	e.params = result.params;
	e.expr = indexWrapper( body, result.table, scope );
	
	return < e[@scope = scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:arrayComprehension(Expr put, Type getType, Id get, Expr from, list[Expr] conds), IndexTable table, Scope scope ) {
	scope = comprehension(scope);
	
	storeResult = store( table, symbolKey( get.name ), getType, scope, true, e@location ); 
	
	return < e[@scope = scope], storeResult.table, storeResult.errorMsg >;
}