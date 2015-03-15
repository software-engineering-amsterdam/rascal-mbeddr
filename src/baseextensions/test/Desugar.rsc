module baseextensions::\test::Desugar
extend \test::TestBase;

import lang::mbeddr::ToC;

import baseextensions::\test::Helper;

public test bool test_constant() {
	str testCaseName = "test_constant";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input =
	"module Test;
	'#constant TAKEOFF = 100;
	'#constant HIGH_SPEED = true;
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

