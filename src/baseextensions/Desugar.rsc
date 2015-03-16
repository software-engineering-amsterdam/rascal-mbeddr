module baseextensions::Desugar
extend desugar::Base;

// LIBRARY IMPORTS
import ext::List;
import ext::Node;

// LOCAL IMPORTS
import typing::IndexTable;
import typing::resolver::Base;
import baseextensions::AST;

// DESUGAR BASEEXTENSIONS

Module desugar_baseextensions( Module m:\module( name, imports, decls ) ) {
	m = desugar_lambdas( m );
	
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
				liftedLambdaGlobals["lambda_function_$<i>"] = symbolRow( l@\type, global(), true );
				
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

Decl desugarDeclMods( Decl d ) {
	export = exported() in d.mods;
	d.mods = exportedMods( d.mods );
	
	if( export ) {
		return d[@header=true];
	}
	
	return d;
}

list[Decl] desugarToList(  Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats) ) {
	export = exported() in d.mods;
	d.mods = exportedMods( d.mods );

	if( export ) {
		return [ d, function(d.mods, d.\type, d.name, d.params)[@header=true] ];
	}
	
	return [ d ];
}

Decl desugarSingle( Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params) ) {
	return desugarDeclMods( d );
}

Decl desugarSingle( Decl d:typeDef(list[Modifier] mods, Type \type, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:struct(list[Modifier] mods, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:struct(list[Modifier] mods, Id name, list[Field] fields) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:union(list[Modifier] mods, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:union(list[Modifier] mods, Id name, list[Field] fields) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:enum(list[Modifier] mods, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:enum(list[Modifier] mods, Id name, list[Enum] enums) ) = desugarDeclMods( d );

Decl desugarVariableMods( Decl d ) {
    export = exported() in d.mods;
    d.mods = exportedMods( d.mods );
	
	if( export ) {
		d.mods += [extern()];
		d@header=true;
	}

	return d;
}

Decl desugarSingle( Decl d:variable(list[Modifier] mods, Type \type, Id name) ) {
	return desugarVariableMods( d );
}

list[Decl] desugarToList( Decl d:variable(list[Modifier] mods, Type \type, Id name, Expr init) ) {
	d = desugarVariableMods( d );
	
	if( exported() in mods ) {
		return [ variable( d.mods, \type, name )[@header=true], variable( exportedMods( mods ), \type, name, init ) ];
	}
	
	return [ d ];
}

// DESUGAR //

Decl desugar( Decl c:constant( Id name, Expr init ) ) = c[@header=true]; 

Literal desugar( Literal l:boolean(str val) ) = val == "true" ? \int("1") : \int("0");
