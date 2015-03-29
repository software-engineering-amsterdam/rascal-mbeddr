module typing::indexer::Indexer

import IO;
import ext::List;
import ext::Node;
import typing::TypeMessage;
import ParseTree;

import util::Util;
import typing::IndexTable;
import typing::Scope;
import typing::resolver::Expression;
import lang::mbeddr::AST;

list[&T <: node] indexer( list[&T <: node] nodeList, IndexTable table, Scope scope ) {
	return for( n <- nodeList ) {
		n = indexWrapper( n, table, scope );
		table = n@indextable;
		append n;
	}
}

&T <: node indexWrapper( &T <: node oldNode, IndexTable table, Scope scope ) {
	result = indexer( oldNode, table, scope );
	newNode = result.astNode;
	
	newNode@indextable = result.table;
	
	if( result.errorMsg != "" ) {
		newNode@message = error( indexError(), result.errorMsg, newNode@location );
	}
	
	return newNode; 
}

// DEFAULT

default
tuple[ &T <: node astNode, IndexTable table, str errorMsg ]
indexer( &T <: node n,
	   	 IndexTable table, 
	   	 Scope scope
	   ) {		 
	return < n, table, "" >;
}

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
	storeResult = store( table, symbolKey(name), symbolRow( \function( \type, parameterTypes( params ) ), scope, true, d@location ) );
	
	result = indexParams( params, storeResult.table, function( scope ) );
	
	d.stats = indexer( stats, result.table, function( scope ) );
	d.params = result.params;
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;	
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:function(list[Modifier] mods, Type \type, id( name ), list[Param] params),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey(name), symbolRow( \function( \type, parameterTypes( params ) ), scope, false, d@location ) );
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:variable(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey(name), symbolRow( \type, scope, false, d@location ) );
	
	return < d[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl d:variable(list[Modifier] mods, Type \type, id( name ), Expr init),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey(name), symbolRow( \type, scope, true, d@location ) );
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
	
	storeResult = store( table, symbolKey( name ), symbolRow( \type, scope, true, f@location ) );
	
	return < f[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl c:const( id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ), symbolRow( \void(), scope, true, c@location ) );
	
	return < c[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTable table, str errorMsg ]
indexer( Decl c:const( id( name ), _ ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ), symbolRow( \void(), scope, true, c@location ) );
	
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
	
	storeResult = store( table, symbolKey( name ), symbolRow( initType,scope,true,d@location ) );

	return < d, storeResult.table, storeResult.errorMsg >;	
}

tuple[ Param astNode, IndexTable table, str errorMsg ]
indexer( Param p:param(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTable table, 
		 Scope scope ) {
	
	storeResult = store( table, symbolKey( name ), symbolRow( \type, scope, true, p@location ) );

	return < p[@scope=scope], storeResult.table, storeResult.errorMsg >;
}

// EXPRESSIONS

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

