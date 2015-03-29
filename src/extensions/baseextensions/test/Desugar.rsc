module extensions::baseextensions::\test::Desugar
extend \test::Base;

import lang::mbeddr::ToC;

import extensions::baseextensions::\test::Helper;

public test bool testConstant() {
	str testCaseName = "testConstant";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module Test;
	'#constant TAKEOFF = 100 + 1;
	'#constant HIGH_SPEED = true;
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		<headerAst,cAst> = splitAst( ast );
		
		passed = validateDesugarOutput( /constant( id("TAKEOFF"), add(_,_) ) := headerAst, "#constant TAKEOFF = 100 + 1;", file = "header file" );
		passed = validateDesugarOutput( /constant( id("HIGH_SPEED"), lit(_) ) := headerAst, "#constant HIGH_SPEED = true;", file = "header file");
		
		printC( ast );
	}
	
	outputResult( testCaseName, passed );
	return passed;
}

public test bool testExportVariableToHeader() {
	str testCaseName = "testExportVariableToHeader";
	outputStart( testCaseName );
	passed = true;
	str input = "
	'	module Test;
	'	exported int8 x = 10;
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		<headerAst,cAst> = splitAst( ast );
		
		passed = validateDesugarOutput( /variable( [extern()], int8(), id("x") ) := headerAst, "extern int8 x;", file = "header file" );
		passed = validateDesugarOutput( /variable( [], int8(), id("x"), lit(\int("10")) ) := cAst, "int8 x = 10;" );
		
		printC( ast );
	}

	outputResult( testCaseName, passed );	
	return passed;
}

public test bool testExportStructToHeader() {
	str testCaseName = "testExportStructToHeader";
	outputStart( testCaseName );
	passed = true;
	str input = "
	'	module Test;
	'	
	'	exported struct TrackPoint {
	'		int8 x;
	'		int8 y;
	'	};
	";	
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		<headerAst,cAst> = splitAst( ast );
		
		passed = validateDesugarOutput( /struct( _, id("TrackPoint"), [ field( int8(), id("x") ), field( int8(), id("y") ) ] ) := headerAst, "struct TrackPoint { int8 x; int8 y; }", file = "header file" );
		
		printC( ast );
	}
	
	outputResult( testCaseName, passed );
	return passed;
}

public test bool testLiftNestedLambdas() {
	str testCaseName = "testLiftNestedLambdas";
	outputStart( testCaseName );
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
		<headerAst,cAst> = splitAst( ast );
		
		passed = validateDesugarOutput( /function( [static()], int8(), id("lambda_function_$1"), _, _ ) := cAst, "function lambda_function_$1" );
		passed = validateDesugarOutput( /function( [static()], int8(), id("lambda_function_$2"), _, _ ) := cAst, "function lambda_function_$2" );
		passed = validateDesugarOutput( /function( [static()], int8(), id("lambda_function_$3"), _, _ ) := cAst, "function lambda_function_$3" );
		
		printC( ast );
	}
	
	outputResult( testCaseName, passed );
	return passed;
}

public test bool testLambdaLiftGlobalVariables() {
	str testCaseName = "testLambdaLiftGlobalVariables";
	outputStart( testCaseName );
	passed = true;
	str input = "
	'module MultipleLambda;
	'int8 y = 10;
	'
	'void main() {
	'	int8(int8) add = [ int8 x | x + y ]; 
	'}
	'
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		<headerAst,cAst> = splitAst( ast );
		
		passed = validateDesugarOutput( /function( [static()], int8(), id("lambda_function_$1"), _, _ ) := cAst, "function lambda_function_$1" );
		
		printC( ast );
	}
	
	outputResult( testCaseName, passed );
	return passed;
}