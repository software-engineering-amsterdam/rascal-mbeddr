module baseextensions::typing::Evaluator
extend typing::Evaluator;

import baseextensions::AST;

// ========= //
// EVALUATOR //
// ========= //

Expr evaluate( Expr e:lambda(list[Param] params, list[Stat] stats ) ) {
	int returns = 0;
	Type return_type = \void();
	
	stats = top-down visit( stats ) {
		case r:returnExpr( Expr expr ) : {
			if( sameFunctionScope( r@scope, e@scope ) ) {
				
				expr_type = getType( expr );
				
				if( returns > 0 && !isEmpty(expr_type) && expr_type in CTypeTree[ return_type ] ) {
					insert r[@message = error("wrong return type",r@location)];
				}
				
				if( returns == 0 ) {
					return_type = expr_type;
				}
				returns += 1;
			}
		}
		
		case r:\return() : {
			if( sameFunctionScope( r@scope, e@scope ) ) {
				if( returns > 0 && return_type != \void() ) {
					insert r@message = error("wrong return type",r@location);
				}
				
				if( returns == 0 ) {
					return_type = \void();
				}
				returns += 1;
			}
		}
	}
	
	e = copyAnnotations( lambda( params, stats ), e );
	
	return e@\type = function( return_type, [ t | param(_,t,_) <- params ] );
}

Expr evaluate( Expr e:lambda(list[Param] params, Expr \return) ) {
	return_type = getType( \return );
	
	if( isEmpty( return_type ) ) { return e; }
	
	e@\type = function( return_type, [ t | param(_,t,_) <- params ] );
	
	return e;
}

Expr evaluate( Expr e:call( l:lambda( list[Param] params, body ), list[Expr] args ) ) {
	l_type = getType( l );
	
	if( function( return_type, args ) := l_type ) {
		return e@\type = return_type;	
	} else {
		return e;
	}
}