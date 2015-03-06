module statemachine::\test::Indexer

import IO;
import List;

import statemachine::\test::Helper;

public test bool test_state_redefinition() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state airborne {}
	' state airborne {}
	'}";
	msgs = indexer( input );
	
	iprintln(msgs);
	return size(msgs) == 1 &&
		   error( "redefinition of \'airborne\'", _ ) := msgs[0];
}