module typing::\test::Indexer
extend \test::Base;

import typing::\test::Helper;

public test bool testDisallowRedefinitonOfVariable() {
	str testCaseName = "testDisallowRedefinitonOfVariable";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'char c = \'x\';
				'char c = \'y\';";
	msgs = indexer( input );
	
	expectedMsgs = [ < indexError(), "redefinition of \'c\'" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowInstantiationOfUninitializedVariable() {
	str testCaseName = "testAllowInstantiationOfUninitializedVariable";
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

public test bool testDisallowInstantiationOfUnitializedVariableWithDifferentType() {
	str testCaseName = "testDisallowInstantiationOfUnitializedVariableWithDifferentType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'char c;
				'int8 c = 1;";
	msgs = indexer( input );
	
	expectedMsgs = [ < indexError(), "redefinition of \'c\' with a different type \'int8\' vs \'char\'" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowDeclarationWithUnkownType() {
	str testCaseName = "testDisallowDeclarationWithUnkownType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'point c;";
	msgs = indexer( input );
	
	expectedMsgs = [ < indexError(), "unknown type name \'point\'" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowDeclarationWithUnkownStructType() {
	str testCaseName = "testDisallowDeclarationWithUnkownStructType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'struct point c;";
	msgs = indexer( input );
	
	expectedMsgs = [ < indexError(), "unkown struct \'point\'" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowDeclarationWithUnkownEnumType() {
	str testCaseName = "testDisallowDeclarationWithUnkownEnumType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'enum color c;";
	msgs = indexer( input );
	
	expectedMsgs = [ < indexError(), "unkown enum \'color\'" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowRedefinitionInDifferentScope() {
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
	
public test bool testDisallowConstantDeclarationWithExpressionThatIsNotStaticallyEvaluatable() {
	str testCaseName = "testDisallowConstantDeclarationWithExpressionThatIsNotStaticallyEvaluatable";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		int8 x = 10;
		#constant y = 10 + x;
	";
	msgs = indexer( input );
	
	expectedMsgs = [ < staticEvaluationError(), "global constants must be statically evaluatable" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}