module UnitTest::AST

extend lang::mbeddr::AST;
	
data Decl 
	= \testCase(list[Modifier] mods, Id name, list[Decl] decls, list[Stat] stats)
	;
	
data Stat
	= \assert( Literal trace, Expr \test )
	| \test( list[Id] tests )
	;