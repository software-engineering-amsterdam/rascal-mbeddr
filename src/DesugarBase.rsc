module DesugarBase

import lang::mbeddr::AST;

default Stat desugar(Stat s) = s;
default Expr desugar(Expr e) = e;
default Decl desugar(Decl d) = d;

list[Modifier] exportedMods( list[Modifier] mods ) {
	if( exported() in mods ) {
		return mods - exported();
	} else {
		return mods + static();
	}
}