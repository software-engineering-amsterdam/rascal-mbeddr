module unittest::Syntax
extend lang::mbeddr::MBeddrC;

syntax Decl
	= \testCase: Modifier* "testcase" Id "{" Stat* "}"
	;
	
syntax Stat
	= \assert: "assert" Expr ";"
	;
	
syntax Expr
	= \test: "test" "[" {Id ","}* "]"
	;
	
keyword Keyword = "test";