module unittest::Syntax

extend lang::mbeddr::MBeddrC;

syntax Decl
	= \testCase: Modifier* "testcase" Id "{" Stat* "}"
	;
	
syntax Stat
	= \assert: "assert" "(" Literal ")" Expr ";"
	| \test: "test" "[" {Id ","}+ "]" ";"
	;