module unittest::typing::Resolver
extend typing::Resolver;

import unittest::AST;
import IO;

anno Type Stat @ \type;

ReturnResolver resolveReturnType( Stat s:\test( list[Id] tests ), Type expectedReturnType, bool ret ) {
	if( isEmpty( expectedReturnType ) ) { expectedReturnType = getType( s ); }
	return < true, expectedReturnType, checkReturnType( s, expectedReturnType ) >;
}

Stat resolve( Stat e:\assert( Expr \test ) ) {
	test_type = getType( \test );

	if( isEmpty( test_type ) ) return e;
	
	if( !( \boolean() := test_type ) ) {
		e@message = error( "an assert expression should be of the type boolean", e@location );
	}
	
	return e;
}

Stat resolve( Stat t:\test( list[Id] tests ) ) {
	symbols = t@symboltable;
	
	t.tests = [ resolveTestCase( id, symbols ) | id <- tests ]; 
	
	return t[@\type=int32()];
}

private Id resolveTestCase( Id n:id( name ), symbols ) {
	if( ! contains( symbols, name ) ) {
		n@message = error( "unkown testcase \'<name>\'", n@location );
	} else if( !( \testCase() := lookup( symbols, name ).\type) ) {
		n@message = error( "referenced test \'<name>\' is not a testcase", n@location);
	}
	
	return n;
}