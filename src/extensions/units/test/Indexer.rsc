module extensions::units::\test::Indexer
extend \test::Base;

import extensions::units::\test::Helper; 

public test bool test_conversion_index() {
	str testCaseName = "test_conversion_index";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		exported conversion mps -\> kmh {
			val as double -\> val / 3.6
			val as double -\> val / 3.6
		}
	";
	msgs = indexer( input );
	
	expectedMsgs = ["The specifiers type is already covered"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
