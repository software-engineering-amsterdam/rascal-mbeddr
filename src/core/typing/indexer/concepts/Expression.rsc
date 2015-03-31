module core::typing::indexer::concepts::Expression
extend core::typing::indexer::Base;

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:subscript(Expr array, Expr sub), IndexTable table, Scope scope ) {
	e.array = indexWrapper( array, table, scope );
	e.sub = indexWrapper( sub, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:call(Expr func, list[Expr] args), IndexTable table, Scope scope ) {
	e.func = indexWrapper( func, table, scope );
	e.args = indexer( args, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:struct(list[Expr] records), IndexTable table, Scope scope ) {
	e.records = indexer( records, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:dotField(Expr record, Id name), IndexTable table, Scope scope ) {
	e.record = indexWrapper( record, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:ptrField(Expr record, Id name), IndexTable table, Scope scope ) {
	e.record = indexWrapper( record, table, scope );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:postIncr(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:postDecr(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:preIncr(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:preDecr(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:addrOf(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:refOf(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:pos(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:neg(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitNot(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:not(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:sizeOfExpr(Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:cast(Type \type, Expr arg), IndexTable table, Scope scope ) {
	e.arg = indexWrapper( arg, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:mul(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e = mul( indexWrapper( lhs, table, scope ), indexWrapper( rhs, table, scope ) );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:div(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:\mod(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:add(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );

	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:sub(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:shl(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:shr(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:lt(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e = lt( indexWrapper( lhs, table, scope ), indexWrapper( rhs, table, scope ) );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:gt(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope ); 
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:leq(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:geq(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:eq(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:neq(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitAnd(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitXor(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope ); 
	e.rhs = indexWrapper( rhs, table, scope );
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitOr(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:and(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope ); 
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:or(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope ); 
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:cond(Expr cond, Expr then, Expr els), IndexTable table, Scope scope ) {
	e.cond = indexWrapper( cond, table, scope ); 
	e.then = indexWrapper( then, table, scope );
	e.els = indexWrapper( els, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:assign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:mulAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:divAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:modAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:addAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:subAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:shlAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:shrAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitAndAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitXorAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}

tuple[ Expr astNode, IndexTable table, str errorMsg ]
indexer( Expr e:bitOrAssign(Expr lhs, Expr rhs), IndexTable table, Scope scope ) {
	e.lhs = indexWrapper( lhs, table, scope );
	e.rhs = indexWrapper( rhs, table, scope );
	
	return < e[@scope=scope], table, "" >;	
}