module baseextensions::Desugar

import IO;
import List;

import util::Util;
import typing::IndexTable;
import baseextensions::AST;
import baseextensions::TypeChecker;

Type desugar( functionRef( list[Type] args, Type returnType ) ) = function( returnType, args );
Decl desugar( constant( Id name, Literal \value ) ) = constant( name, \value );

Module transform( m:\module( name, imports, decls ) ) {
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
	
	return insertDecls( m, liftedLambdas );
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

private Module insertDecls( m:\module( name, imports, decls ), list[Decl] toInsert ) = copyAnnotations( \module( name, imports, toInsert + decls ), m );

private list[Stat] liftLambdaBody( list[Stat] b ) = b;
private list[Stat] liftLambdaBody( Expr e ) = [returnExpr(e)];

private list[Type] extractParamTypes( list[Param] params ) = [ paramType | param(_,paramType,_) <- params ];
private list[str] extractParamNames( list[Param] params ) = [ paramName | param(_, _, id( paramName )) <- params ];