module extensions::unittest::\test::Resolver
extend \test::Base;

import extensions::unittest::\test::Helper;
import extensions::unittest::typing::TypeMessage;

public test bool testDisallowAssertStatementWithNonBoolean() {
	str testCaseName = "testDisallowAssertStatementWithNonBoolean";
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

	expectedMsgs = [< assertAbuseError(), "an assert expression should be of the type boolean" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowRunningUndefinedTestCase() {
	str testCaseName = "testDisallowRunningUndefinedTestCase";
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
	
	expectedMsgs = [< referenceError(), "unkown testcase \'HelloWorld\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowRunnigFunctionAsTestCase() {
	str testCaseName = "testDisallowRunnigFunctionAsTestCase";
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
	
	expectedMsgs = [< typeMismatchError(), "referenced test \'HelloWorld\' is not a testcase" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}