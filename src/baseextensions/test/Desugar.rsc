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

public test bool test_exported_initialized_variable() {
	str testCaseName = "test_exported_initialized_variable";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
	'	module Test;
	'	exported int8 x = 10;
	";
	headerOutput = [variable( [extern()], int8(), id("x") )];
	cOutput = [variable( [], int8(), id("x"), lit(\int("10")) )];
	
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		passed = validateDesugarOutput( testCaseName, ast, headerOutput, cOutput );
		printC( ast );
	}
	
	return passed;
}

public test bool test_exported_initialized_struct() {
	str testCaseName = "test_struct";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
	'	module Test;
	'	
	'	exported struct TrackPoint {
	'		int8 x;
	'		int8 y;
	'	};
	";
	headerOutput = [struct( [], id("TrackPoint"), [ field( int8(), id("x") ), field( int8(), id("y") ) ] )];
	cOutput = [];
	
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		passed = validateDesugarOutput( testCaseName, ast, headerOutput, cOutput );
		printC( ast );
	}
	return passed;
}

public test bool test_multiple_lambda() {
	str testCaseName = "test_multiple_lambda";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
	'module MultipleLambda;
	'
	'int8(int8,int8) add = [ int8 x, int8 y | 
	'	int32 r = [ | x + y ]();
	'	
	'	int32() f = [ | return x; ];
	'	
	'	return x + y;
	'];
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}