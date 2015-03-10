module unittest::\test::Constraints
extend \test::TestBase;

import unittest::\test::Helper;

public test bool test_assert_constraint() {
	str input = 
	" module Test;
	' 
	' void main() {
	'  assert 0 == 0;
	' }
	";
	msgs = constraints( input );
	
	if( PRINT ) {
		iprintln(msgs);	
	}
	
	return size(msgs) > 0 &&
		   error( "assert statement is constrained to test case bodies", _ ) := msgs[0];
}

public test bool test_testcase_constraint() {
	str input = 
	"module Test;
	' 
	' void main() {
	'  exported testcase tester { }
	' }
	";
	msgs = constraints( input );
	
	if( PRINT ) {
		iprintln(msgs);	
	}
	
	return size(msgs) > 0 &&
		   error( "testcase declaration is constrained to the global scope", _ ) := msgs[0];
}

public test bool test_test_return() {
	str input = 
	"module Test;
	' 
	' testcase HelloWorld { }
	
	' void main() {
	'  test[ HelloWorld ];
	' }
	";
	msgs = constraints( input );
	
	if( PRINT ) {
		iprintln(msgs);	
	}
	
	return size(msgs) > 0 &&
		   error( "expecting return statement", _ ) := msgs[0];
}
