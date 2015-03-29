module extensions::statemachine::\test::Constraints
extend \test::Base;

import extensions::statemachine::\test::Helper;

public test bool testDisallowSendStatementOutsideState() {
	str testCaseName = "testDisallowSendStatementOutsideState";
	str input = 
	" module Test;
	' 
	' void main() {
	'  send crashed();
	' }
	";
	msgs = constraints( input );

	expectedMsgs = [ < constraintError(), "send statement is constrained to entry or exit bodies" > ];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowSendStatementInState() {
	str testCaseName = "testAllowSendStatementInState";
	str input = 
	" module Test;
	' 
	'statemachine FlightAnalyzer {
	' state airborne {
	'  entry { send crashed(); }
	' }
	'}
	";
	msgs = constraints( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowSendInIfStatementInState() {
	str testCaseName = "testAllowSendInIfStatementInState";
	str input = 
	" module Test;
	' 
	'statemachine FlightAnalyzer {
	' state airborne {
	'  entry { if( true ) { send crashed(); } }
	' }
	'}
	";
	msgs = constraints( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}