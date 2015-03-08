module baseextensions::Syntax

extend lang::mbeddr::MBeddrC;

//syntax Type 
//	= functionRef: "(" {Type ","}* ")" "=\>" "(" Type ")"  
//	;
	
syntax Decl 
	= constant: "#constant" Id "=" Literal ";"
	;
	
syntax Expr
 	= lambda: "[" {Param ","}* "|" Stat* "]"
 	| lambda: "[" {Param ","}* "|" Expr "]"
	;