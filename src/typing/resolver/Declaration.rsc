module typing::resolver::Declaration
extend typing::resolver::Base;

import typing::Util;

// DECLARATION EVALUATORS

default Decl resolve( Decl d ) = d;

Decl resolve( Decl f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) ) {
	int returns = 0;
	
	f = top-down-break visit( f ) {
		case r:returnExpr(Expr expr) : {
			if( sameFunctionScope( r@scope, function(f@scope) ) ) {
				returns += 1;
				expr_type = getType( expr );
				
				if( !( isEmpty(expr_type ) ) && !( \type in CTypeTree[ expr_type ] ) ) {
					expr@message = error(  "return type \'<typeToString( expr_type )>\' not a subtype of expected type \'<typeToString(\type)>\'", \type@location );
					insert r.expr = expr;	
				}
			}
		}
	}
	
	if( returns == 0 && \type != \void() ) {
		return f@message = error(  "control reaches end of non-void function", f@location );
	}
	
	return f;	
}

Decl resolve( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init) ) {
	init_type = getType( init );
	
	if( id( id( typeName ) ) := \type ) {
		if( <typeName,typedef()> in v@typetable ) {
			\type = v@typetable[ <typeName,typedef()> ].\type;
		} else {
			return v;
		}
	}
	
	if( struct( id( structName ) ) := \type ) {
		return resolveStruct( v, init, structName );
	} elseif( !isEmpty(init_type ) ) {
		v = resolveVariableAssignment( v, init_type );	
	} 
	
	return v;
}