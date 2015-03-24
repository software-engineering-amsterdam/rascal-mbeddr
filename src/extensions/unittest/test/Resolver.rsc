module extensions::unittest::\test::Resolver
extend \test::Base;

import extensions::unittest::\test::Helper;

public test bool test_assert_boolean() {
	str testCaseName = "test_assert_boolean";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' 
	' testcase main {
	'  assert 1; 
	' }
	";
	msgs = resolver( input );

	expectedMsgs = ["an assert expression should be of the type boolean"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_unkown_testcase_test() {
	str testCaseName = "test_unkown_testcase_test";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'
	' int32 main() {
	'  return test [ HelloWorld ];
	' } 
	";
	msgs = resolver( input );
	
	expectedMsgs = ["unkown testcase \'HelloWorld\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_wrong_testcase_test() {
	str testCaseName = "test_wrong_testcase_test";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' void HelloWorld();
	' int32 main() {
	'  return test [ HelloWorld ];
	' } 
	";
	msgs = resolver( input );
	
	expectedMsgs = ["referenced test \'HelloWorld\' is not a testcase"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}