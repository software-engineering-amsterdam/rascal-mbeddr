module UnitTest::Syntax

extend lang::mbeddr::C;

syntax Decl
	= \testCase: Modifier* "testcase" Id "{" Decl* Stat* "}"
	;
	
syntax Stat
	= \assert: "assert" "(" Literal ")" Expr ";"
	| \test: "test" "[" {Id ","}+ "]" ";"
	;