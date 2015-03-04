module unittest::typing::Indexer
extend typing::Indexer;

import unittest::AST;
import unittest::typing::Scope;

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:testCase(list[Modifier] mods, id( name ), list[Stat] stats),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {
	storeResult = store( tables, name, < testCase(), scope, true > );
	d.stats = indexer( stats, storeResult.tables, \test( scope ) );
			 
	return < d, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:\test( list[Id] tests ),
		 IndexTables tables,
		 Scope scope
		) {
	
	return < e[@scope=scope], tables, "" >;	
}