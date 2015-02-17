module BaseExtensions::Syntax

extend lang::mbeddr::C;

syntax Type 
	= functionRef: "(" {Type ","}* ")" "=\>" "(" Type ")"  
	;
	
syntax Decl 
	= constant: "#constant" Id "=" Literal ";"
	;
	
syntax Expr
 	= lambda: "[" {Param ","}* "|" Decl* Stat* "]"
 	| lambda: "[" {Param ","}* "|" Expr "]"
	;