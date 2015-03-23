module unittest::typing::Constraints
extend typing::constraints::Constraints;

import Node;
import IO;

import unittest::AST;
import unittest::typing::Scope;

Stat constraint( Stat a:\assert( Expr \test ) ) {
	if( ! inTest( a@scope ) ) {
		a@message = error( "assert statement is constrained to test case bodies", a@location );
	}
	return a;
}

Decl constraint( Decl t:\testCase(list[Modifier] mods, Id name, list[Stat] stats) ) {
	if( ! inGlobal( t@scope ) ) {
		t@message = error( "testcase declaration is constrained to the global scope", t@location );
	}
	return t;
}