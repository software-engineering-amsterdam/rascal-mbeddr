module extensions::baseextensions::AST

extend lang::mbeddr::AST;

data Decl
	= constant(Id name, Expr init);

data Expr
	= lambda(list[Param] params, list[Stat] body )
	| lambda(list[Param] params, Expr expr)
	| arrayComprehension(Expr put, Type getType, Id get, Expr from, list[Expr] conds)
	;