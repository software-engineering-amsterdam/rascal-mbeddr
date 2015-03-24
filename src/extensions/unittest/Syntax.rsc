module extensions::unittest::Syntax
extend lang::mbeddr::MBeddrC;

syntax Decl
	= \testCase: Modifier* "testcase" Id "{" Stat* "}"
	;
	
syntax Stat
	= \assert: "assert" Expr ";"
	| \test: "return" "test" "[" {Id ","}* "]"
	;
	
keyword Keyword = "test";