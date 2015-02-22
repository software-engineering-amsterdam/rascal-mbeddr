module baseextensions::Desugar

import IO;
import List;

import baseextensions::AST;

Type desugar( functionRef( list[Type] args, Type returnType ) ) = function( returnType, args );
Decl desugar( constant( Id name, Literal \value ) ) = constant( name, \value );

Module transform( \module( name, imports, decls ) ) {
	int i = 0;
	bool foundLambda;
	list[Decl] lambdas = [];
	map[str, list[Param]] lambdaArguments = ();

	// Find lambdas and lift to top-level function
	do {
		foundLambda = false;
		
		decls += lambdas;
		lambdas = [];
		
		decls = top-down visit( decls ) {
			// TODO: Use type system to detect return type
			case lambda( list[Param] params, stats_or_expr ) : { 
				i += 1;
				foundLambda = true; 
				liftedParams = findLiftedParams( stats_or_expr, params );
				
				lambdas += function( [static()], \void(), id("lambda_function_$<i>"), params + liftedParams, stats_or_expr );
				lambdaArguments["lambda_function_$<i>"] = liftedParams;
				
				insert var( id( "lambda_function_$<i>" ) );
			}
		}
		
	} while(foundLambda);
	
	// Inspect call graph and alter calls to lambda functions to append closure environment args 
	decls = visit( decls ) {
		case call( var( id( str name ) ), list[Expr] args ) : {
			if( name in lambdaArguments ) {
				insert call( var( id( name ) ), args + [ var( identifier ) | param( _, _, identifier ) <- lambdaArguments[ name ] ] );
			}
		}
	}
	
	return \module( name, imports, decls );
}

private list[Param] findLiftedParams( lambdaBody, list[Param] lambdaParams ) {
	result = [];
	paramNames = extractParamNames( lambdaParams );

	visit( lambdaBody ) {
	// Detect all variable usages outside the scope of the lambda function
	// TODO: Global variables shouldn't be detected
		case var( id( varName ) ) : {
			if( ! ( varName in paramNames ) ) {
				// TODO: Use type system to detect param type
				result += param( [], \void(), id( varName ) );
			}		
		}
	}
	
	return result;
}

private list[str] extractParamNames( list[Param] params ) = [ paramName | param(_, _, id( paramName )) <- params ];