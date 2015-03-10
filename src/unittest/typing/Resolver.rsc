module unittest::typing::Resolver
extend typing::Resolver;

import unittest::AST;

Stat resolve( Stat e:\assert( Expr \test ) ) {
	test_type = getType( \test );

	if( isEmpty( test_type ) ) return e;
	
	if( !( \boolean() := test_type ) ) {
		e@message = error( "an assert expression should be of the type boolean", e@location );
	}
	
	return e;
}

Expr resolve( Expr t:\test( list[Id] tests ) ) {
	symbols = t@symboltable;
	
	t.tests = for( n:id( name ) <- tests ) {
		
		if( ! (name in symbols) ) {
			n@message = error( "unkown testcase \'<name>\'", n@location );
		} else if( !( \testCase() := symbols[name].\type) ) {
			n@message = error( "referenced test \'<name>\' is not a testcase", n@location);
		}
		
		append n;
	}
	
	return t[@\type=int32()];
}