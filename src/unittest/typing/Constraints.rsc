module unittest::typing::Constraints
extend typing::Constraints;

import Node;
import IO;

import unittest::AST;
import unittest::typing::Scope;

Stat constraint( Stat s:returnExpr( t:\test( list[Id] tests ) ) ) {
	if( "message" in getAnnotations(t) && t@message.msg == "expecting return statement" ) {
		t = delAnnotation( t, "message" );
	}
	
	return s.expr = t;
}

Expr constraint( Expr t:\test( list[Id] tests ) ) {
	return t[@message = error( "expecting return statement", t@location )];
}

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