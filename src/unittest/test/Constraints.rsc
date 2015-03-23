module unittest::\test::Constraints
extend \test::Base;

import unittest::\test::Helper;

public test bool test_assert_constraint() {
	str testCaseName = "test_assert_constraint";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' 
	' void main() {
	'  assert 0 == 0;
	' }
	";
	msgs = constraints( input );
	
	expectedMsgs = ["assert statement is constrained to test case bodies"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_testcase_constraint() {
	str testCaseName = "test_testcase_constraint";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' 
	' void main() {
	'  exported testcase tester { }
	' }
	";
	msgs = constraints( input );

	expectedMsgs = ["testcase declaration is constrained to the global scope"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_test_return() {
	str testCaseName = "test_test_return";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' 
	' testcase HelloWorld { }
	
	' void main() {
	'  test[ HelloWorld ];
	' }
	";
	msgs = constraints( input );
	
	expectedMsgs = ["expecting return statement"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
