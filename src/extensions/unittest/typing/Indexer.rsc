module extensions::unittest::typing::Indexer
extend typing::indexer::Indexer;

import extensions::unittest::AST;
import extensions::unittest::typing::Scope;

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:testCase(list[Modifier] mods, id( name ), list[Stat] stats),
	   	 IndexTable table, 
	   	 Scope scope
	   ) {
	storeResult = store( table, symbolKey(name), symbolRow(testCase(), scope, true ) );
	d.stats = indexer( stats, storeResult.table, \test( scope ) );
			 
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:\test( list[Id] tests ),
		 IndexTable table,
		 Scope scope
		) {
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\assert( Expr \test ),
		 IndexTable table,
		 Scope scope
		) {
	s.\test = indexWrapper( \test, table, scope );
	return < s[@scope=scope], table, "" >;	
}