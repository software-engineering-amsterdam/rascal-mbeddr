module BaseExtensions::Desugar

import BaseExtensions::AST;

Module desugar( Module ast ) {
	return visit( ast ) {
		case constant( Id name, Literal \value ) => constant( name, \value )
		case functionRef( list[Type] args, Type returnType ) => function( returnType, args )
		
		// TODO: Add closures to parent, use type system to detect return type
		case lambda( list[Param] params, list[Decl] decls, list[Stat] stats ) : { 
			closure = function( [static()], \void(), id("lambda_function"), params, decls, stats ); 
			insert var( "lambda_function" );
		}
		case lambda( list[Param] params, Expr expr ) : {
			closure = function( [static()], \void(), id("lambda_function"), params, [], \returnExpr( expr ) );
			insert var( "lambda_function" );
		}
	}
}