module typing::Constraints

import IO;
import Message;

import lang::mbeddr::AST;

import typing::IndexTable;
import typing::Scope;

default &T <: node constraint( &T <: node n ) = n;

Stat constraint( Stat c:\case(Expr guard, Stat body) ) {
	if( ! inSwitch( c@scope ) ) {
		c@message = error( "case statement is constrained to switch bodies", c@location );
	}
	return c;
}

Stat constraint( Stat d:\default(Stat body) ) {
	if( ! inSwitch( d@scope ) ) {
		d@message = error( "default statement is constrained to switch bodies", d@location );
	}
	return d;
}

Decl constraint( Decl d:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] body) ) {
	if( ! inGlobal( d@scope ) ) {
		d@message = error( "function declaration is constrained to global scope", d@location );
	}
	return d;
}