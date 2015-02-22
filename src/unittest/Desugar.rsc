module unittest::Desugar

import unittest::AST;

Decl desugar( \testCase(mods, name, stats), str ModuleName ) {
	int i = 0;
	list[Stat] body = [
		variable( [], int8(), "failures", 0 ),
		printf_expr("running test @ <ModuleName>:test_<name>:<i>\n")
	];
	
	body += visit( stats ) {
		case \assert( trace, \test ) : {
			i += 1;
			insert ifThen( not( \test ), [
				postIncr( var( "failures" ) ),
				printf_expr("FAILED: @<ModuleName>:test_<name>:<i>\n"),
				printf_expr("testID = <trace>\n")
			] );
		}
	}
	
	body += \return( var( "failures" ) );

	return function(mods, int8(), "test_" + name, [], body);
}

Stat desugar( \test( list[Id] tests ) ) {
	list[Stat] body = [
		variable( [], \int32(), id( "failureVals" ), 0 ),
		variable( [], pointer( \int32() ), id( "failures" ), addrOf( var( id( "failureVals" ) ) ) )
	];
	
	body += for( \test <- tests ) {
		append assign( var( id( "failures" ) ), add( var( id( "failures" ) ), call( var( \test ) ) ) ); 
	}
	
	body += returnExpr( var( id( "failureVals" ) ) );
	
	return block( body );
}

private Expr printf_expr( str arg ) {
	return call( var( "printf" ), [ lit( string( arg ) ) ] );
}