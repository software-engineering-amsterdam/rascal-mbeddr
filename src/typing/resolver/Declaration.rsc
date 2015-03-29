module typing::resolver::Declaration
extend typing::resolver::Base;

import ext::Node;
import typing::Util;

alias ReturnResolver = tuple[bool,Type,Stat];

default ReturnResolver resolveReturnType( Stat s, Type expectedReturnType, bool ret ) = <ret,expectedReturnType,s>;

ReturnResolver resolveStatBodyReturnType( Stat s, Type expectedReturnType, bool ret ) {
	<ret,expectedReturnType,body> = resolveReturnType( s.body, expectedReturnType, ret );
	return <ret,expectedReturnType,s[body=body]>; 
}

ReturnResolver resolveReturnType( Stat s:labeled(Id label, Stat stat), Type expectedReturnType, bool ret ) {
	<ret,expectedReturnType,stat> = resolveReturnType( stat, expectedReturnType, ret );
	return <ret,expectedReturnType,s[stat=stat]>;
}
ReturnResolver resolveReturnType( Stat s:ifThenElse(Expr cond, Stat body, Stat els), Type expectedReturnType, bool ret ) {
	<ret,expectedReturnType,body> = resolveReturnType( body, expectedReturnType, ret );
	<ret,expectedReturnType,els> = resolveReturnType( els, expectedReturnType, ret );
	s.body = body;
	s.els = els;
	return <ret,expectedReturnType,s>;
}
ReturnResolver resolveReturnType( Stat s:block(list[Stat] stats), Type expectedReturnType, bool ret ) {
	<ret,expectedReturnType,stats> = resolveReturnType( stats, expectedReturnType, ret );
	s.stats = stats;
	return <ret,expectedReturnType,s>;
}

tuple[bool,Type,list[Stat]] resolveReturnType( list[Stat] stats, Type expectedReturnType, bool ret ) {
	stats = for( stat <- stats ) {
		<ret,expectedReturnType,stat> = resolveReturnType( stat, expectedReturnType, ret );
		append stat;
	}
	
	return <ret,expectedReturnType,stats>;
}

ReturnResolver resolveReturnType( Stat s:\case(Expr guard, Stat body), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );
ReturnResolver resolveReturnType( Stat s:\default(Stat body), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );
ReturnResolver resolveReturnType( Stat s:ifThen(Expr cond, Stat body), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );
ReturnResolver resolveReturnType( Stat s:\switch(Expr cond, Stat body), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );
ReturnResolver resolveReturnType( Stat s:\while(Expr cond, Stat body), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );
ReturnResolver resolveReturnType( Stat s:doWhile(Stat body, Expr cond), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );
ReturnResolver resolveReturnType( Stat s:\for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body), Type expectedReturnType, bool ret ) = resolveStatBodyReturnType( s, expectedReturnType, ret );

ReturnResolver resolveReturnType( Stat s:\return(), Type expectedReturnType, bool ret ) {
	if( isEmpty( expectedReturnType ) ) { expectedReturnType = \void(); }
	
	return <false, expectedReturnType, checkReturnType( s, expectedReturnType )>;
}
ReturnResolver resolveReturnType( Stat s:\returnExpr(Expr expr), Type expectedReturnType, bool ret ) { 
	if( isEmpty( expectedReturnType ) ) { expectedReturnType = getType( expr ); }
	
	s.expr = checkReturnType( s.expr, expectedReturnType );
	return <true, expectedReturnType, s>; 
}

&T <: node checkReturnType( &T <: node n, Type expectedReturnType ) {
	n_type = getType( n );
	
	if( !( isEmpty( n_type ) ) && !( getType( expectedReturnType ) in CTypeTree[ n_type ] ) ) {
		n@message = error( returnMismatchError(), "return type \'<typeToString( n_type )>\' not a subtype of expected type \'<typeToString( expectedReturnType )>\'", n@location ); 	
	}
	
	return n;
}

default Decl resolve( Decl d ) = d;

tuple[&T<:node,Type,list[Stat]] resolveFunctionReturnType( &T <: node n, list[Stat] stats, Type expectedReturnType ) {
	< hasReturn, returnType, stats > = resolveReturnType( stats, expectedReturnType, false );

	if(!hasReturn && returnType != \void() ) {
		n@message = error( returnMismatchError(), "control reaches end of non-void function", n@location );
	}
	
	return < n, returnType, stats >;
}

Decl resolve( Decl f:function(_, _, _, _, _) ) {
	<f,_,stats> = resolveFunctionReturnType( f, f.stats, f.\type );
	return f[stats=stats];
}


Decl resolve( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init) ) {
	init_type = getType( init );
	v.\type = getType( \type );

	if( struct( id( structName ) ) := \type ) {
		return resolveStruct( v, init, structName );
	} elseif( !isEmpty(init_type ) ) {
		v = resolveVariableAssignment( v, init_type );	
	} 
	
	return v;
}