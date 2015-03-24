module extensions::unittest::typing::Indexer
extend typing::indexer::Indexer;

import extensions::unittest::AST;
import extensions::unittest::typing::Scope;

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:testCase(list[Modifier] mods, id( name ), list[Stat] stats),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {
	storeResult = store( tables, name, < testCase(), scope, true > );
	d.stats = indexer( stats, storeResult.tables, \test( scope ) );
			 
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:\test( list[Id] tests ),
		 IndexTables tables,
		 Scope scope
		) {
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\assert( Expr \test ),
		 IndexTables tables,
		 Scope scope
		) {
	s.\test = indexWrapper( \test, tables, scope );
	return < s[@scope=scope], tables, "" >;	
}