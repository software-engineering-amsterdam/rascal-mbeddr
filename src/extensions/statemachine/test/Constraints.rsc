module extensions::statemachine::\test::Constraints
extend \test::Base;

import extensions::statemachine::\test::Helper;

public test bool test_send_constraint_1() {
	str testCaseName = "test_send_constraint_1";
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

public test bool test_send_constraint_2() {
	str testCaseName = "test_send_constraint_2";
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

public test bool test_send_constraint_3() {
	str testCaseName = "test_send_constraint_3";
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