module extensions::unittest::\test::Constraints
extend \test::Base;

import extensions::unittest::\test::Helper;

public test bool testDisallowAssertOutsideTestCase() {
	str testCaseName = "testDisallowAssertOutsideTestCase";
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
	
	expectedMsgs = [< constraintError(), "assert statement is constrained to test case bodies" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowTestCaseOutsideGlobalScope() {
	str testCaseName = "testDisallowTestCaseOutsideGlobalScope";
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

	expectedMsgs = [< constraintError(), "testcase declaration is constrained to the global scope" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowTestStatementInFunctionBody() {
	str testCaseName = "testAllowTestStatementInFunctionBody";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' 
	' testcase HelloWorld { }
	
	' void main() {
	'  return test[ HelloWorld ];
	' }
	";
	msgs = constraints( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
