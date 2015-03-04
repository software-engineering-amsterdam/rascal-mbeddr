module baseextensions::Desugar
extend Desugar;

// LIBRARY IMPORTS
import List;

// LOCAL IMPORTS
import typing::IndexTable;
import baseextensions::AST;

Module desugar_baseextensions( Module m:\module( name, imports, decls ) ) {
	int i = 0;
	list[Decl] liftedLambdas = [];
	SymbolTable liftedLambdaGlobals = (); 

	// Find lambdas and lift to top-level function
	m = innermost visit( m ) {
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
	
	m.decls = liftedLambdas + m.decls;
	return m;
}

Decl desugar( Decl f:function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats) ) {
	return f.mods = exportedMods( f.mods );
}

Decl desugar( Decl f:function(list[Modifier] mods, Type \type, Id name, list[Param] params) ) {
	return f.mods = exportedMods( f.mods );
}

Decl desugar( Decl c:constant( Id name, Literal \value ) ) = constant( name, \value );

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