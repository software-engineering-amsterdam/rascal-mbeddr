module typing::constraints::Constraints

import IO;
import Message;

import lang::mbeddr::AST;
import util::Util;

import typing::IndexTable;
import typing::Scope;
import typing::Util;

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

Expr constraint( Expr e:addrOf( lit( l ) ) ) {
	return e@message = error( "cannot take the address of an rvalue of type \'<litToString(l)>\'", e@location );
}