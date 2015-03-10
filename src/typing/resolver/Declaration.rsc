module typing::resolver::Declaration
extend typing::resolver::ResolverBase;

import typing::resolver::Util;

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
		if( function( Type return_type, list[Type] args ) := \type ) {
			
			if( function( Type init_return_type, list[Type] init_args ) := init_type ) {
				
				if( !(return_type in CTypeTree[init_return_type]) ) {
					v@message = error( "expected function with return type \'<typeToString(return_type)>\' but got \'<typeToString(init_return_type)>\'", v@location );
				} else if( args != init_args ) {
					v@message = error( "expected function with argument types \'<for( arg <- args ){><typeToString(arg)>,<}>\' but got \'<for( init_arg <- init_args ){><typeToString(init_arg)>,<}>\'", v@location );
				}
				
			} else {
				return v@message = error( "expected function but got \'<typeToString(init_type)>\'", v@location );
			}
			 
		} elseif( pointer(_) := \type && pointer(_) := init_type ) {
			return resolvePointerAssignment( v, \type, init_type );
		} elseif( !( \type in CTypeTree[ init_type ] ) ) {
			return v@message = error(  "\'<typeToString(init_type)>\' not a subtype of \'<typeToString(\type)>\'", v@location );
		}
	} 
	
	return v;
}
