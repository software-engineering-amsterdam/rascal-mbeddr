module unittest::\test::Desugar
extend \test::Base;

import unittest::\test::Helper;

public test bool test_testcase() {
	str testCaseName = "test_test_case";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		testcase main {
			assert 1 == 1;
		}
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_run_testcase() {
	str testCaseName = "test_run_testcase";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		testcase main {
			assert 1 == 1;
		}
		
		int32 runTests() {
			return test [main];
		}
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}