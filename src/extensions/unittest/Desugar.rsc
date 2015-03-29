module extensions::unittest::Desugar
extend desugar::Base;

import util::ext::List;

import extensions::unittest::AST;  

Module desugarUnitTest( Module m ) {
	return visit( m ) {
		case d:\testCase(_,_,_) => desugarTestCase( d, joinList( [ name | id( name ) <- m.name.parts ], "/" ) ) 
	}
}

Decl desugarTestCase( Decl d:\testCase(mods, id(name), stats), str ModuleName ) {
	int i = 0;
	list[Stat] body = [
		decl( variable( [], int8(), id("failures"), lit( \int("0") ) ) ),
		expr( printfExpr("running test @<ModuleName>:test_<name>:<i>\n") )
	];
	
	body += visit( stats ) {
		case s:\assert( \test ) : {
			i += 1;
			insert ifThen( not( \test ), block( [
				expr( postIncr( var( id( "failures" ) ) ) ),
				expr( printfExpr("FAILED: @<ModuleName>:test_<name>:<i>\n") ), 
				expr( printfExpr("testID = <s@location>\n") )
			] ) );
		}
	}
	
	body += \returnExpr( var( id( "failures" ) ) );

	return function(d.mods, int8(), id("test_" + name), [], body);
}

public Stat desugar( Stat s:t:\test( list[Id] tests ) ) {
	list[Stat] body = [
		decl( variable( [], \int32(), id( "failureVals" ), lit( \int("0") ) ) ),
		decl( variable( [], pointer( \int32() ), id( "failures" ), addrOf( var( id( "failureVals" ) ) ) ) )
	];
	
	body += [ desugarTestCall( \test ) | \test <- tests ]; 
	
	body += returnExpr( var( id( "failureVals" ) ) );
	
	return block( body );
}

private Stat desugarTestCall( Id \test ) {
	return expr( assign( var( id( "failures" ) ), add( var( id( "failures" ) ), call( var( \test ), [] ) ) ) );
}

private Expr printfExpr( str arg ) {
	return call( var( id( "printf" ) ), [ lit( string( arg ) ) ] );
}