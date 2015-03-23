module unittest::AST

extend lang::mbeddr::AST;
	
data Decl 
	= \testCase(list[Modifier] mods, Id name, list[Stat] stats)
	;
	
data Stat
	= \assert( Expr \test )
	| \test( list[Id] tests )
	;

data Type
	= testCase()
	;