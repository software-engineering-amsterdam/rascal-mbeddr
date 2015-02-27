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


Module createIndexTable( m:\module( name, imports, decls ) ) = copyAnnotations( \module( name, imports, indexer( decls, <(), ()>, global() ) ), m );

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
	newNode = copyAnnotations( newNode, oldNode );
	
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
indexer( Stat b:block(list[Stat] stats),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {
	n = block( indexer( stats, tables, block( scope ) ) );		 
	return < n, tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:ifThen(Expr cond, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	n = ifThen( cond, indexWrapper( body, tables, block( scope ) ) );		 
	return < n, tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:ifThenElse(Expr cond, Stat body, Stat els),
		 IndexTables tables, 
		 Scope scope ) {
	n = ifThenElse( cond, indexWrapper( body, tables, block( scope ) ), indexWrapper( els, tables, block( scope ) ) );
	return < n, tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	n = \for(init, conds, update, indexWrapper( body, tables, block( scope ) ) );
	return < n, tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:decl( d ),
		 IndexTables tables, 
		 Scope scope ) {
	result = indexWrapper( d, tables, scope );
	table = result@symboltable;
	types = result@typetable;
	n = decl( result );
	n = setAnnotations( n, getAnnotations( s ) );
	
	return < n, < table, types >, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:labeled(Id label, Stat stat),
		 IndexTables tables, 
		 Scope scope ) {
	s = labeled( indexWrapper( label, tables, scope ), indexWrapper( stat, tables, scope ) );
	return < s, tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\case(Expr guard, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	errorMsg = "";
	
	if( ! inSwitch( scope ) ) {
		errorMsg = "\'case\' statement is not allowed here";
	}
	
	s = \case( indexWrapper( guard, tables, scope ), indexWrapper( body, tables, block( scope ) ) );
	return < s, tables, errorMsg >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\default(Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	errorMsg = "";
	
	if( !( \switch( _ ) := scope ) ) {
		errorMsg = "\'default\' statement is not allowed here";
	}
		
	s = \default( indexWrapper( body, tables, block( scope ) ) );
	return < s, tables, errorMsg >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:expr(Expr e),
		 IndexTables tables, 
		 Scope scope ) {
	s = expr( indexWrapper( e, tables, scope ) );
	return < s, tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\switch(Expr cond, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s = \switch( indexWrapper( cond, tables, scope ), indexWrapper( body, tables, \switch( scope ) ) );
	return < s, tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\while(Expr cond, Stat body),
		 IndexTables tables, 
		 Scope scope ) {
	s = \while( indexWrapper( cond, tables, scope ), indexWrapper( body, tables, block( scope ) ) );
	return < s, tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:doWhile(Stat body, Expr cond),
		 IndexTables tables, 
		 Scope scope ) {
	s = doWhile( indexWrapper( body, tables, block( scope ) ), indexWrapper( cond, tables, scope ) );
	return < s, tables, "" >;
} 

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat r:\return(),
		 IndexTables tables, 
		 Scope scope ) {
	return < r[@scope = scope], tables, "" >;
}

tuple[ Stat astNode, IndexTables tables, str errorMsg ]
indexer( Stat s:\returnExpr(Expr expr),
		 IndexTables tables, 
		 Scope scope ) {
	
	s = \returnExpr( indexWrapper( expr, tables, scope ) );
	
	return < s[@scope = scope], tables, "" >;
} 

// DECLARATIONS

tuple[ list[Param] params, IndexTables tables ] indexParams(list[Param] params, IndexTables tables, Scope scope ) {
	params = indexer( params, tables, function( scope ) );
	
	symbols = size( params ) > 0 ? params[-1]@symboltable : tables.symbols;
	types = size( params ) > 0 ? params[-1]@typetable : tables.types;
		
	return < params, <symbols, types> >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] body),
		 IndexTables tables, 
		 Scope scope ) {
		 
	if( ! (global() := scope) ) {

		return< f, tables, "function definition is not allowed here" >;
		
	} else {
		scope = function(scope);
		storeResult = store( tables, name, < \function( \type, parameterTypes( params ) ), scope, true > );
		
		result = indexParams( params, storeResult.tables, scope );
		
		body = indexer( body, result.tables, scope );
		n = function( mods, \type, id( name ), result.params, body );
	
		return < n[@scope=scope], tables, storeResult.errorMsg >;	
	}	
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \function( \type, parameterTypes( params ) ), scope, false > );
	
	return < f, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl v:variable(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, false > );
	
	return < v, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, true > );
	init = indexWrapper( init, storeResult.tables, scope );
	
	v = variable(mods, \type, id( name ), init);
	
	return < v, storeResult.tables, storeResult.errorMsg >;
}

// TYPE DEFINITIONS

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl t:typeDef(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,typedef()>, < \type, scope, true > );
	
	return < t, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl s:struct(list[Modifier] mods, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,struct()>, < struct( [] ), scope, false > );
	
	return < s, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl s:struct(list[Modifier] mods, id( name ), list[Field] fields),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,struct()>, < struct( fields ), scope, true > );
	s = struct( mods, id( name ), indexer( fields, tables, block( scope ) ) );
	
	return < s, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl e:enum(list[Modifier] mods, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,enum()>, < enum( [] ), scope, false > );
	
	return < e, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl e:enum(list[Modifier] mods, id( name ), list[Enum] enums),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,enum()>, < enum( enums ), scope, false > );
	
	e = enum( mods, id( name ), indexer( table, types, block( scope ), enums ) );
	
	return < e, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl u:union(list[Modifier] mods, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,union()>, < union( [] ), scope, false > );
	
	return < u, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl u:union(list[Modifier] mods, id( name ), list[Field] fields),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, <name,union()>, < union( fields ), scope, true > );
	u = union( mods, id( name ), indexer( table, types, block( scope ), fields ) );
	
	
	return < u, storeResult.tables, storeResult.errorMsg >;
}

// Fields

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl f:field( Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, true > );
	
	return < f, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl c:const( id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \void(), scope, true > );
	
	return < c, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl c:const( id( name ), _ ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \void(), scope, true > );
	
	return < c, storeResult.tables, storeResult.errorMsg >;
}

tuple[ Param astNode, IndexTables tables, str errorMsg ]
indexer( Param p:param(list[Modifier] mods, Type \type, id( name ) ),
		 IndexTables tables, 
		 Scope scope ) {
	
	storeResult = store( tables, name, < \type, scope, true > );

	return < p, storeResult.tables, storeResult.errorMsg >;
}

// EXPRESSIONS

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:subscript(Expr array, Expr sub), IndexTables tables, Scope scope ) {
	e = subscript( indexWrapper( array, tables, scope ), indexWrapper( sub, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:call(Expr func, list[Expr] args), IndexTables tables, Scope scope ) {
	e = call( indexWrapper( func, tables, scope ), indexer( args, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:struct(list[Expr] records), IndexTables tables, Scope scope ) {
	e = struct( indexer( records, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:dotField(Expr record, Id name), IndexTables tables, Scope scope ) {
	e = dotField( indexWrapper( record, tables, scope ), name );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:ptrField(Expr record, Id name), IndexTables tables, Scope scope ) {
	e = ptrField( indexWrapper( record, tables, scope ), name );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:postIncr(Expr arg), IndexTables tables, Scope scope ) {
	e = postIncr( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:postDecr(Expr arg), IndexTables tables, Scope scope ) {
	e = postDecr( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:preIncr(Expr arg), IndexTables tables, Scope scope ) {
	e = preIncr( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:preDecr(Expr arg), IndexTables tables, Scope scope ) {
	e = preDecr( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:addrOf(Expr arg), IndexTables tables, Scope scope ) {
	e = addrOf( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:refOf(Expr arg), IndexTables tables, Scope scope ) {
	e = refOf( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:pos(Expr arg), IndexTables tables, Scope scope ) {
	e = pos( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:neg(Expr arg), IndexTables tables, Scope scope ) {
	e = neg( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitNot(Expr arg), IndexTables tables, Scope scope ) {
	e = bitNot( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:not(Expr arg), IndexTables tables, Scope scope ) {
	e = ( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:sizeOfExpr(Expr arg), IndexTables tables, Scope scope ) {
	e = sizeOfExpr( indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:cast(Type \type, Expr arg), IndexTables tables, Scope scope ) {
	e = cast( \type, indexWrapper( arg, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:mul(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = mul( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:div(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = div( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:\mod(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = \mod( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:add(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = add( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:sub(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = sub( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shl(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = shl( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shr(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = shr( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:lt(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = lt( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:gt(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = gt( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:leq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = leq( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:geq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = geq( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:eq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = eq( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:neq(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = neq( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitAnd(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = bitAnd( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitXor(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = bitXor( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitOr(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = bitOr( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:and(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = and( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:or(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = or( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:cond(Expr cond, Expr then, Expr els), IndexTables tables, Scope scope ) {
	e = cond( indexWrapper( cond, tables, scope ), indexWrapper( then, tables, scope ), indexWrapper( els, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:assign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = assign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:mulAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = mulAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:divAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = divAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:modAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = modAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:addAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = addAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:subAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = subAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shlAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = shlAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:shrAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = shrAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitAndAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = bitAndAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitXorAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = bitXorAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

tuple[ Expr astNode, IndexTables tables, str errorMsg ]
indexer( Expr e:bitOrAssign(Expr lhs, Expr rhs), IndexTables tables, Scope scope ) {
	e = bitOrAssign( indexWrapper( lhs, tables, scope ), indexWrapper( rhs, tables, scope ) );
	return < e, tables, "" >;	
}

