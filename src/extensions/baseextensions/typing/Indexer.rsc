module extensions::baseextensions::typing::Indexer
extend typing::indexer::Indexer;

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
