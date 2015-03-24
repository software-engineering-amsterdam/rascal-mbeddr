module extensions::units::Syntax
extend lang::mbeddr::MBeddrC;

syntax Decl
	= unitConversion: Modifier* "conversion" Id "-\>" Id "{" ConversionDecl* "}"
	| unit: Modifier* "unit" Id ":=" Spec "for" Id
	| unit: Modifier* "unit" Id "for" Id
	;

syntax ConversionDecl
	= conversion: "val" "as" Type "-\>" Expr
	| conversion: "val" "-\>" Expr
	;
	
syntax Spec
	= 
	;

syntax Expr
	= convert: "convert" "(" Expr "-\>" Id ")"  
	;

syntax Type
	= unit: Type "/" Id "/"
	;

syntax Literal
	= unit: Literal Id
	;
	
keyword Keyword
	= "conversion"
	| "unit"
	| "convert"
	;
