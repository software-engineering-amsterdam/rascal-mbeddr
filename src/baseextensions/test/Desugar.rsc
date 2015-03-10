module baseextensions::\test::Desugar
extend \test::TestBase;

import lang::mbeddr::ToC;

import baseextensions::\test::Helper;

public test bool test_constant() {
	str input =
	"module Test;
	'#constant TAKEOFF = 100;
	'#constant HIGH_SPEED = true;
	";
	ast = createAST( input );
	ast = desugarModule( ast );
	if( PRINT ) {
		h = module2h( ast );
		c = module2c( ast );
		println( h );
		println("===============================");
		println( c );
	}
	
	return true;
	
}

