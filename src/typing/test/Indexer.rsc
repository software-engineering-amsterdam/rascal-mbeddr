module typing::\test::Indexer
extend \test::Base;

import typing::\test::Helper;

public test bool test_redefenition_1() {
	str testCaseName = "test_redefenition_1";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'char c = \'x\';
				'char c = \'y\';";
	msgs = indexer( input );
	
	expectedMsgs = ["redefinition of \'c\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_redefenition_2() {
	str testCaseName = "test_redefenition_2";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'char c;
				'char c = \'y\';";
	msgs = indexer( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_redefenition_3() {
	str testCaseName = "test_redefenition_3";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'char c;
				'int8 c = 1;";
	msgs = indexer( input );
	
	expectedMsgs = ["redefinition of \'c\' with a different type \'int8\' vs \'char\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_custom_type() {
	str testCaseName = "test_custom_type";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'point c;";
	msgs = indexer( input );
	
	expectedMsgs = ["unknown type name \'point\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_struct() {
	str testCaseName = "test_struct";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'struct point c;";
	msgs = indexer( input );
	
	expectedMsgs = ["unkown struct \'point\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_enum() {
	str testCaseName = "test_enum";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'enum color c;";
	msgs = indexer( input );
	
	expectedMsgs = ["unkown enum \'color\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_scope() {
	str testCaseName = "test_scope";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'int8 x = 9;
				'void fun() {
				'	if( true ) {
				'		int8 x = 10;
				'	}
				'	int8 x = 11;
				'}";
	msgs = indexer( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
	
public test bool test_constant_indexer() {
	str testCaseName = "test_constant_indexer";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		int8 x = 10;
		#constant y = 10 + x;
	";
	msgs = indexer( input );
	
	expectedMsgs = ["global constants must be statically evaluatable"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}