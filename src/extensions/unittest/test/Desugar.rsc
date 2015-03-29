module extensions::unittest::\test::Desugar
extend \test::Base;

import extensions::unittest::\test::Helper;

public test bool testDesugarTestCase() {
	str testCaseName = "testDesugarTestCase";
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

public test bool testDesugarRunTestCase() {
	str testCaseName = "testDesugarRunTestCase";
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