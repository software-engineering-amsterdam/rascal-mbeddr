module core::typing::indexer::concepts::Statement
extend core::typing::indexer::Base;


// BLOCK STATEMENTS

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:block(list[Stat] stats),
	   	 IndexTable table, 
	   	 Scope scope
	   ) {
	s.stats = indexer( stats, table, block( scope ) );		 
	
	return < s[@scope=scope], table, "" >;
}

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:ifThen(Expr cond, Stat body),
		 IndexTable table, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, table, block( scope ) );
	s.body = indexWrapper( body, table, block( scope ) );		 
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:ifThenElse(Expr cond, Stat body, Stat els),
		 IndexTable table, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, table, block( scope ) );
	s.body = indexWrapper( body, table, block( scope ) );
	s.els = indexWrapper( els, table, block( scope ) );
	
	return < s[@scope=scope], table, "" >;
}

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body),
		 IndexTable table, 
		 Scope scope ) {
	s.init = indexer( init, table, block( scope ) );
	s.conds = indexer( conds, table, block( scope ) );
	s.update = indexer( update, table, block( scope ) );
	s.body = indexWrapper( body, table, block( scope ) );
	
	return < s[@scope=scope], table, "" >;
}

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:decl( Decl decl ),
		 IndexTable table, 
		 Scope scope ) {
	result = indexWrapper( decl, table, scope );
	table = result@indextable;
	s.decl = result;
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:labeled(Id label, Stat stat),
		 IndexTable table, 
		 Scope scope ) {
	s.label = indexWrapper( label, table, scope );
	s.stat = indexWrapper( stat, table, scope );

	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\case(Expr guard, Stat body),
		 IndexTable table, 
		 Scope scope ) {
	s.guard = indexWrapper( guard, table, scope );
	s.body = indexWrapper( body, table, block( scope ) );
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\default(Stat body),
		 IndexTable table, 
		 Scope scope ) {
	s.body = indexWrapper( body, table, block( scope ) );
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:expr(Expr expr),
		 IndexTable table, 
		 Scope scope ) {
	s.expr = indexWrapper( expr, table, scope );
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\switch(Expr cond, Stat body),
		 IndexTable table, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, table, scope );
	s.body = indexWrapper( body, table, \switch( scope ) );
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\while(Expr cond, Stat body),
		 IndexTable table, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, table, scope );
	s.body = indexWrapper( body, table, block( scope ) );
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:doWhile(Stat body, Expr cond),
		 IndexTable table, 
		 Scope scope ) {
	s.body = indexWrapper( body, table, block( scope ) );
	s.cond = indexWrapper( cond, table, block( scope ) );
	
	return < s[@scope=scope], table, "" >;
} 

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat r:\return(),
		 IndexTable table, 
		 Scope scope ) {
	return < r[@scope=scope], table, "" >;
}

tuple[ Stat astNode, IndexTable table, str errorMsg ]
indexer( Stat s:\returnExpr(Expr expr),
		 IndexTable table, 
		 Scope scope ) {
	s.expr = indexWrapper( expr, table, scope );
	
	return < s[@scope=scope], table, "" >;
} 
