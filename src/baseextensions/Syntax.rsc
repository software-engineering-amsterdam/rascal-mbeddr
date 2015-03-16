module baseextensions::Syntax

extend lang::mbeddr::MBeddrC;

//syntax Type 
//	= functionRef: "(" {Type ","}* ")" "=\>" "(" Type ")"  
//	;
	
syntax Expr
 	= lambda: "[" {Param ","}* "|" Stat* "]"
 	| lambda: "[" {Param ","}* "|" Expr "]"
	;