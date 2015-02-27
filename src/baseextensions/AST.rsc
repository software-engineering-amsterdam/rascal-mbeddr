module baseextensions::AST

extend lang::mbeddr::AST;

data Decl
	= constant(Id name, Literal \value);

data Expr
	= lambda(list[Param] params, list[Stat] body )
	| lambda(list[Param] params, Expr expr);