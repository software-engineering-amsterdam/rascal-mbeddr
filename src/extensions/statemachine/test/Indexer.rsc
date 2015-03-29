module extensions::statemachine::\test::Indexer
extend \test::Base;

import extensions::statemachine::\test::Helper;

public test bool test_empty_statemachine() {
	str testCaseName = "test_empty_statemachine";
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	'}";
	msgs = indexer( input );

	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_state_redefinition() {
	str testCaseName = "test_state_redefinition";
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state airborne {}
	' state airborne {}
	'}";
	msgs = indexer( input );
	
	expectedMsgs = [< indexError(), "redefinition of \'airborne\'" >];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_var_redefinition() {
	str testCaseName = "test_var_redefinition";
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' var int16 points = 0
	' var int16 points = 0
	'}";
	msgs = indexer( input );
	
	expectedMsgs = [< indexError(), "redefinition of \'points\'" >];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_inevent_redefinition() {
	str testCaseName = "test_inevent_redefinition";
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' in event next()
	'}";
	msgs = indexer( input );
	
	expectedMsgs = [< indexError(), "redefinition of \'next\'" >];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_redefinition() {
	str testCaseName = "test_outevent_redefinition";
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	' out event crashNotification() =\> doNothing
	'}";
	msgs = indexer( input );
	
	expectedMsgs = [< indexError(), "redefinition of \'crashNotification\'" >];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_inevent() {
	str testCaseName = "test_inevent";
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next( int32 points )
	' in event reset()
	'}";
	msgs = indexer( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

