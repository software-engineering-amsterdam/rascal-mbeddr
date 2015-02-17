module BaseExtensions::AST

extend lang::mbeddr::AST;

data Type
	= functionRef(list[Type] args, Type returnTypes);

data Decl
	= constant(Id name, Literal \value);

data Expr
	= lambda(list[Param] params, list[Decl] decls, list[Stat] stats )
	| lambda(list[Param] params, Expr expr);