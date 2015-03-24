module extensions::baseextensions::AST

extend lang::mbeddr::AST;

data Decl
	= constant(Id name, Expr init);

data Expr
	= lambda(list[Param] params, list[Stat] body )
	| lambda(list[Param] params, Expr expr);