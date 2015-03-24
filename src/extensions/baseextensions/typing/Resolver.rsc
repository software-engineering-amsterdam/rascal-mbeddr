module extensions::baseextensions::typing::Resolver
extend typing::Resolver;

import extensions::baseextensions::AST;

Expr resolve( Expr e:lambda(list[Param] params, list[Stat] body ) ) {
	<e,returnType,body> = resolveFunctionReturnType( e, body, empty() );
	e.body = body;
	
	return e@\type = function( returnType, [ t | param(_,t,_) <- params ] );
}

Expr resolve( Expr e:lambda(list[Param] params, Expr \return) ) {
	returnType = getType( \return );
	
	if( isEmpty( returnType ) ) { return e; }
	
	e@\type = function( returnType, [ t | param(_,t,_) <- params ] );
	
	return e;
}

Expr resolve( Expr e:call( l:lambda( list[Param] params, body ), list[Expr] args ) ) {
	l_type = getType( l );
	
	if( function( returnType, args ) := l_type ) {
		return e@\type = returnType;	
	} else {
		return e;
	}
}