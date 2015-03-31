module extensions::baseextensions::typing::Resolver
extend core::typing::resolver::Resolver;

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
	lType = getType( l );
	
	if( function( returnType, args ) := lType ) {
		return e@\type = returnType;	
	} else {
		return e;
	}
}

Expr constraintToBoolean( Expr e ) {
	eType = getType( e );
	
	if( !isEmpty(eType) && !(boolean() := eType) ) {
		e@message = error( conditionalMismatchError(), "Expected something of boolean type, but got something of \'<typeToString(eType)>\'", e@location );
	}
	
	return e;
}

private Type getArrayType( array(_), Type itemType ) = array( itemType );
private Type getArrayType( array(_,int dimension), Type itemType ) = array( itemType, dimension );

Expr resolve( Expr e:arrayComprehension(Expr put, Type _, Id get, Expr from, list[Expr] conds) ) {
	fromType = getType( e.from );
	putType = getType( e.put );
	
	if( isEmpty( fromType ) || isEmpty( putType ) ) { return e; }
	
	e.conds = [ constraintToBoolean( cond ) | cond <- conds ];
	
	if( array( Type itemType, int dimension ) := fromType ) {
		
		if( ! inTypeTree( CTypeTree, e.getType, itemType ) ) {
			e.get@message = error( nonFittingTypesError(), "Expected array with items of type \'<typeToString(e.getType)>\' but got array with items of type \'<typeToString(itemType)>\'", e.get@location );
		} else {
		
			e@\type = getArrayType( fromType, itemType );
		}
		
	} else if( array( Type itemType ) := fromType ) {
		e.from@message = error( typeMismatchError(), "Array comprehensions can only retrieve items from arrays with dimensions", e.from@location );
	} else {
		e.from@message = error( typeMismatchError(), "Array comprehensions can only retrieve items from arrays", e.from@location );
	}
	
	return e;
}