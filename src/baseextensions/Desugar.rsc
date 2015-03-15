module baseextensions::Desugar
extend DesugarBase;

// LIBRARY IMPORTS
import ext::List;
import ext::Node;

// LOCAL IMPORTS
import typing::IndexTable;
import baseextensions::AST;

// DESUGAR BASEEXTENSIONS

Module desugar_baseextensions( Module m:\module( name, imports, decls ) ) {
	m = desugar_lambdas( m );
	
	m = headerFunctions( m );
	
	m = visit( m ) {
		case Decl d => desugar_mods( d )
	}
	
	return m;
}

private Module desugar_lambdas( Module m:\module( name, imports, decls ) ) {
	int i = 0;
	list[Decl] liftedLambdas = [];
	SymbolTable liftedLambdaGlobals = (); 

	// Find lambdas and lift to top-level function
	solve( m ) {
		m = visit( m ) {
			case l:lambda( list[Param] params, body ) : { 
				i += 1;
				liftedParams = findLiftedParams( body, params, liftedLambdaGlobals );
		
				liftedLambdas += function( [static()], l@\type, id("lambda_function_$<i>"), params + liftedParams, liftLambdaBody( body ) );
				liftedLambdaGlobals["lambda_function_$<i>"] = < l@\type, global(), true >;
				
				// TODO detect uses of lambda and replace those 
				n = var( id( "lambda_function_$<i>" ) );
				insert n;
			}
		}
	}
	
	m.decls = liftedLambdas + m.decls;
	return m;
}

private list[Param] findLiftedParams( lambdaBody, list[Param] lambdaParams, SymbolTable globals ) {
	result = [];
	paramNames = extractParamNames( lambdaParams );

	top-down visit( lambdaBody ) {
		// Detect all variable usages outside the scope of the lambda function
		case e:var( id( varName ) ) : {
			if( ! ( varName in paramNames ) && ! ( varName in globals ) ) {
				result += param( [], e@symboltable[ varName ].\type, id( varName ) );
			}		
		}
	}
	
	return result;
}

private SymbolTable findGlobals( SymbolTable symbols ) {
	result = ();
	for( ( name : row ) <- symbols, global( row.scope ) ) {
		result[ name ] = row;
	}
	return result;	
}

private list[Stat] liftLambdaBody( list[Stat] b ) = b;
private list[Stat] liftLambdaBody( Expr e ) = [returnExpr(e)];

private list[Type] extractParamTypes( list[Param] params ) = [ paramType | param(_,paramType,_) <- params ];
private list[str] extractParamNames( list[Param] params ) = [ paramName | param(_, _, id( paramName )) <- params ];

// DESUGAR DECL MODIFIERS //

Module headerFunctions( Module m ) {
	exportedFuns = [];
	visit( m ) {
		case Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats) : {
			if( exported() in d.mods ) {
				exportedFuns += function(d.mods, d.\type, d.name, d.params)[@header=true];
			}
		}
	
		case Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params) : {
			if( exported() in d.mods ) {
				exportedFuns += d[@header=true];
			}
		}
	}
	m.decls += exportedFuns;
	return m;
}

list[Decl] desugarToList(  Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats) ) {
	if( exported() in d.mods ) {
		return [ d, function(d.mods, d.\type, d.name, d.params)[@header=true] ];
	}
	
	return [ d ];
}

Decl desugar( Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params) ) {
	if( exported() in d.mods ) {
		return d[@header=true];
	}
	
	return d;
}

default Decl desugar_mods( Decl d ) = d;

Decl desugar_mods( Decl f:function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats) ) {
	return f.mods = exportedMods( f.mods );
}
Decl desugar_mods( Decl f:function(list[Modifier] mods, Type \type, Id name, list[Param] params) ) {
	return f.mods = exportedMods( f.mods );
}
Decl desugar_mods( Decl d:typeDef(list[Modifier] mods, Type \type, Id name) ) { 
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:struct(list[Modifier] mods, Id name) ) {
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:struct(list[Modifier] mods, Id name, list[Field] fields) ) {
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:union(list[Modifier] mods, Id name) ) {
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:union(list[Modifier] mods, Id name, list[Field] fields) ) {
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:enum(list[Modifier] mods, Id name) ) {
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:enum(list[Modifier] mods, Id name, list[Enum] enums) ) {
	d.mods = exportedMods( d.mods );
	return d[@header=exported() in mods];
}
Decl desugar_mods( Decl d:variable(list[Modifier] mods, Type \type, Id name) ) {
	d.mods = exportedMods( d.mods );
	return d;
}
Decl desugar_mods( Decl d:variable(list[Modifier] mods, Type \type, Id name, Expr init) ) {
	d.mods = exportedMods( d.mods );
	return d;
}

// DESUGAR //

Decl desugar( Decl c:constant( Id name, Literal \value ) ) = preProcessor( "#define <name.name> (<getChildren(\value)[0]>)" )[@header=true];

Literal desugar( Literal l:boolean(str val) ) = val == "true" ? \int("1") : \int("0");
