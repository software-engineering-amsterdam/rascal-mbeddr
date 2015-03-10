module statemachine::\test::Indexer
extend \test::TestBase;

import statemachine::\test::Helper;

public test bool test_state_redefinition() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state airborne {}
	' state airborne {}
	'}";
	msgs = indexer( input );
	
	return size(msgs) == 1 &&
		   error( "redefinition of \'airborne\'", _ ) := msgs[0];
}

public test bool test_var_redefinition() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' var int16 points = 0
	' var int16 points = 0
	'}";
	msgs = indexer( input );
	
	return size(msgs) == 1 &&
		   error( "redefinition of \'points\'", _ ) := msgs[0];
}

public test bool test_inevent_redefinition() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' in event next()
	'}";
	msgs = indexer( input );
	
	return size(msgs) == 1 &&
		   error( "redefinition of \'next\'", _ ) := msgs[0];
}

public test bool test_outevent_redefinition() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	' out event crashNotification() =\> doNothing
	'}";
	msgs = indexer( input );
	
	return size(msgs) == 1 &&
		   error( "redefinition of \'crashNotification\'", _ ) := msgs[0];
}

public test bool test_inevent() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next( int32 points )
	' in event reset()
	'}";
	msgs = indexer( input );
	
	return size(msgs) == 0;
}

