module extensions::statemachine::\test::Indexer
extend \test::Base;

import extensions::statemachine::\test::Helper;

public test bool testAllowEmptyStatemachine() {
	str testCaseName = "testAllowEmptyStatemachine";
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

public test bool testDisallowStateRedefinition() {
	str testCaseName = "testDisallowStateRedefinition";
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

public test bool testDisallowRedefinitionVar() {
	str testCaseName = "testDisallowRedefinitionVar";
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

public test bool testDisallowRedefinitionInEvent() {
	str testCaseName = "testDisallowRedefinitionInEvent";
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

public test bool testDisallowRedfeinitionOfOutEvent() {
	str testCaseName = "testDisallowRedfeinitionOfOutEvent";
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

public test bool testAllowRedefinitionOfInEventWithDifferentName() {
	str testCaseName = "testAllowRedefinitionOfInEventWithDifferentName";
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

