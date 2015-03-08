module typing::Indexer

import IO;
import List;
import Node;
import Message;
import ParseTree;

import util::Util;
import typing::IndexTable;
import typing::Scope;
import lang::mbeddr::AST;

list[&T <: node] indexer( list[&T <: node] nodeList, IndexTables tables, Scope scope ) {
	return for( n <- nodeList ) {
		n = indexWrapper( n, tables, scope );
		tables.symbols = n@symboltable;
		tables.types = n@typetable;
		append n;
	}
}

&T <: node indexWrapper( &T <: node oldNode, IndexTables tables, Scope scope ) {
	result = indexer( oldNode, tables, scope );
	newNode = result.astNode;
	
	newNode@symboltable = result.tables.symbols;
	newNode@typetable = result.tables.types;
	
	if( result.errorMsg != "" ) {
		newNode@message = error( result.errorMsg, newNode@location );
	}
	
	return newNode; 
}

// DEFAULT

default
tuple[ &T <: node astNode, IndexTables tables, str errorMsg ]
indexer( &T <: node n,
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {		 
	return < n, tables, "" >;
}

// BLOCK STATEMENTS

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:block(list[Stat] stats),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {
	s.stats = indexer( stats, tables, block( scope ) );		 
	
	return < s[@scope=scope], tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:ifThen(Expr cond, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, tables, block( scope ) );
	s.body = indexWrapper( body, tables, block( scope ) );		 
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:ifThenElse(Expr cond, Stat body, Stat els),
		 IndexTables tables, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, tables, block( scope ) );
	s.body = indexWrapper( body, tables, block( scope ) );
	s.els = indexWrapper( els, tables, block( scope ) );
	
	return < s[@scope=scope], tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s.init = indexer( init, tables, block( scope ) );
	s.conds = indexer( conds, tables, block( scope ) );
	s.update = indexer( update, tables, block( scope ) );
	s.body = indexWrapper( body, tables, block( scope ) );
	
	return < s[@scope=scope], tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:decl( Decl decl ),
		 IndexTables tables, 
		 Scope scope ) {
	result = indexWrapper( decl, tables, scope );
	table = result@symboltable;
	types = result@typetable;
	s.decl = result;
	
	return < s[@scope=scope], < table, types >, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:labeled(Id label, Stat stat),
		 IndexTables tables, 
		 Scope scope ) {
	s.label = indexWrapper( label, tables, scope );
	s.stat = indexWrapper( stat, tables, scope );

	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\case(Expr guard, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s.guard = indexWrapper( guard, tables, scope );
	s.body = indexWrapper( body, tables, block( scope ) );
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\default(Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s.body = indexWrapper( body, tables, block( scope ) );
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:expr(Expr expr),
		 IndexTables tables, 
		 Scope scope ) {
	s.expr = indexWrapper( expr, tables, scope );
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\switch(Expr cond, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, tables, scope );
	s.body = indexWrapper( body, tables, \switch( scope ) );
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\while(Expr cond, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s.cond = indexWrapper( cond, tables, scope );
	s.body = indexWrapper( body, tables, block( scope ) );
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:doWhile(Stat body, Expr cond),
		 IndexTables tables, 
		 Scope scope ) {
	s.body = indexWrapper( body, tables, block( scope ) );
	s.cond = indexWrapper( cond, tables, block( scope ) );
	
	return < s[@scope=scope], tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat r:\return(),
		 IndexTables tables, 
		 Scope scope ) {
	return < r[@scope=scope], tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\returnExpr(Expr expr),
		 IndexTables tables, 
		 Scope scope ) {
	s.expr = indexWrapper( expr, tables, scope );
	
	return < s[@scope=scope], tables, "" >;
} 

// DECLARATIONS

tuple[ list[Param] params, IndexTables tables ] indexParams(list[Param] params, IndexTables tables, Scope scope ) {
	params = indexer( params, tables, scope );
	
	symbols = size( params ) > 0 ? params[-1]@symboltable : tables.symbols;
	types = size( params ) > 0 ? params[-1]@typetable : tables.types;
		
	return < params, <symbols, types> >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats),
		 IndexTables tables, 
		 Scope scope ) {
	storeResult = store( tables, name, < \function( \type, parameterTypes( params ) ), scope, true > );
	
	result = indexParams( params, storeResult.tables, function( scope ) );
	
	d.stats = indexer( stats, result.tables, function( scope ) );
	d.params = result.params;
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;	
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:function(list[Modifier] mods, Type \type, id( name ), list[Param] params),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \function( \type, parameterTypes( params ) ), scope, false > );
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:variable(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, false > );
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:variable(list[Modifier] mods, Type \type, id( name ), Expr init),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, true > );
	d.init = indexWrapper( init, storeResult.tables, scope );
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

// TYPE DEFINITIONS

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl t:typeDef(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,typedef()>, < \type, scope, true > );
	
	return < t[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl s:struct(list[Modifier] mods, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,struct()>, < struct( [] ), scope, false > );
	
	return < s[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl s:struct(list[Modifier] mods, id( name ), list[Field] fields),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,struct()>, < struct( fields ), scope, true > );
	s.fields = indexer( fields, tables, block( scope ) );
	
	return < s[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl e:enum(list[Modifier] mods, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,enum()>, < enum( [] ), scope, false > );
	
	return < e[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl e:enum(list[Modifier] mods, id( name ), list[Enum] enums),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,enum()>, < enum( enums ), scope, false > );
	
	e.enums = indexer( enums, tables, block( scope ) );
	
	return < e[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl u:union(list[Modifier] mods, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,union()>, < union( [] ), scope, false > );
	
	return < u[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl u:union(list[Modifier] mods, id( name ), list[Field] fields),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,union()>, < union( fields ), scope, true > );
	u.fields = indexer( fields, tables, block( scope ) );
	
	
	return < u[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

// Fields

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl f:field( Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, true > );
	
	return < f[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl c:const( id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \void(), scope, true > );
	
	return < c[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl c:const( id( name ), _ ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \void(), scope, true > );
	
	return < c[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Param astNode, IndexTables tables, str errorMsg ]
indexer( Param p:param(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, true > );

	return < p[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

// EXPRESSIONS

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:subscript(Expr array, Expr sub), IndexTables tables, Scope scope ) {
	e.array = indexWrapper( array, tables, scope );
	e.sub = indexWrapper( sub, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:call(Expr func, list[Expr] args), IndexTables tables, Scope scope ) {
	e.func = indexWrapper( func, tables, scope );
	e.args = indexer( args, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:struct(list[Expr] records), IndexTables tables, Scope scope ) {
	e.records = indexer( records, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:dotField(Expr record, Id name), IndexTables tables, Scope scope ) {
	e.record = indexWrapper( record, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:ptrField(Expr record, Id name), IndexTables tables, Scope scope ) {
	e.record = indexWrapper( record, tables, scope );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:postIncr(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:postDecr(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:preIncr(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:preDecr(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:addrOf(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:refOf(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:pos(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:neg(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitNot(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:not(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:sizeOfExpr(Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:cast(Type \type, Expr arg), IndexTables tables, Scope scope ) {
	e.arg = indexWrapper( arg, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:mul(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = mul( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:div(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:\mod(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:add(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );

	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:sub(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shl(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shr(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:lt(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = lt( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:gt(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope ); 
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:leq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:geq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:eq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:neq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitAnd(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitXor(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope ); 
	e.rhs = indexWrapper( rhs, tables, scope );
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitOr(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:and(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope ); 
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:or(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope ); 
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:cond(Expr cond, Expr then, Expr els), IndexTables tables, Scope scope ) {
	e.cond = indexWrapper( cond, tables, scope ); 
	e.then = indexWrapper( then, tables, scope );
	e.els = indexWrapper( els, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:assign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:mulAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:divAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:modAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:addAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:subAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shlAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shrAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitAndAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitXorAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitOrAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e.lhs = indexWrapper( lhs, tables, scope );
	e.rhs = indexWrapper( rhs, tables, scope );
	
	return < e[@scope=scope], tables, "" >;	
}

