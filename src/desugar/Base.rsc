module desugar::Base

import lang::mbeddr::AST;
import typing::resolver::ResolverBase;

default &T <: node desugarSingle( &T <: node n ) = n;

default list[&T <: node] desugarToList( &T <: node n ) = [];

default &T <: node desugar( &T <: node n ) = n;
default Stat desugar(Stat s) { iprintln(s); return  s; }
default Expr desugar(Expr e) = e;
default Decl desugar(Decl d) = d;

list[Modifier] exportedMods( list[Modifier] mods ) {
	if( exported() in mods ) {
		return mods - exported();
	} else {
		return mods + static();
	}
}

Stat desugar( Stat s:expr( Expr e:call( dotField( Expr record, id( name ) ), list[Expr] args ) ) ) {
	return desugarDotFieldCall( getType( record ), record, name, args );
}