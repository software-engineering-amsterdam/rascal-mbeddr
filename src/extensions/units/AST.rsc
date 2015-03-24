module extensions::units::AST
extend lang::mbeddr::AST;

anno loc ConversionDecl@location;
anno loc Spec@location; 

anno Message ConversionDecl@message;
anno Message Spec@message;

data Decl
	= unitConversion( list[Modifier] mods, Id fromUnit, Id toUnit, list[ConversionDecl] body )
	| unit( list[Modifier] mods, Id name, Spec specification, Id description )
	| unit( list[Modifier] mods, Id name, Id description )
	;

data ConversionDecl
	= conversion( Type \type, Expr conv ) 
	| conversion( Expr conv )
	;

data Spec
	= spec()
	;
	
data Expr
	= convert( Expr \value, Id unit )  
	;
	
data Type
	= unit( Type \type, Id unit )
	;
	
data Literal
	= unit( Literal lit, Id unit )
	;