module unittest::\test::Resolver
extend \test::TestBase;

import unittest::\test::Helper;

public test bool test_assert_boolean() {
	str input = 
	"module Test;
	' 
	' testcase main {
	'  assert 1; 
	' }
	";
	msgs = resolver( input );
	
	if( PRINT ) {
		iprintln(msgs);	
	}
	
	return size(msgs) > 0 &&
		   error( "an assert expression should be of the type boolean", _ ) := msgs[0];
}

public test bool test_unkown_testcase_test() {
	str input = 
	"module Test;
	'
	' void main() {
	'  test [ HelloWorld ];
	' } 
	";
	msgs = resolver( input );
	
	if( PRINT ) {
		iprintln(msgs);	
	}
	
	return size(msgs) > 0 &&
		   error( "unkown testcase \'HelloWorld\'", _ ) := msgs[0];
}
public test bool test_wrong_testcase_test() {
	str input = 
	"module Test;
	' void HelloWorld();
	' void main() {
	'  test [ HelloWorld ];
	' } 
	";
	msgs = resolver( input );
	
	if( PRINT ) {
		iprintln(msgs);	
	}
	
	return size(msgs) > 0 &&
		   error( "referenced test \'HelloWorld\' is not a testcase", _ ) := msgs[0];
}