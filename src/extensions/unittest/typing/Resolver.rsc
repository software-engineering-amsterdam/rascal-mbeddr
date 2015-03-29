module extensions::unittest::typing::Resolver
extend typing::Resolver;

import extensions::unittest::AST;
import extensions::unittest::typing::TypeMessage;
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
		e@message = error( assertAbuseError(), "an assert expression should be of the type boolean", e@location );
	}
	
	return e;
}

Stat resolve( Stat t:\test( list[Id] tests ) ) {
	table = t@indextable;
	
	t.tests = [ resolveTestCase( id, table ) | id <- tests ]; 
	
	return t[@\type=int32()];
}

private Id resolveTestCase( Id n:id( name ), IndexTable table ) {
	if( ! contains( table, symbolKey(name) ) ) {
		n@message = error( referenceError(), "unkown testcase \'<name>\'", n@location );
	} else if( !( \testCase() := lookup( table, symbolKey(name) ).\type) ) {
		n@message = error( typeMismatchError(), "referenced test \'<name>\' is not a testcase", n@location);
	}
	
	return n;
}