module extensions::unittest::typing::Constraints
extend core::typing::constraints::Constraints;

import Node;
import IO;

import extensions::unittest::AST;
import extensions::unittest::typing::Scope;

Stat constraint( Stat a:\assert( Expr \test ) ) {
	if( ! inTest( a@scope ) ) {
		a@message = error( constraintError(), "assert statement is constrained to test case bodies", a@location );
	}
	return a;
}

Decl constraint( Decl t:\testCase(list[Modifier] mods, Id name, list[Stat] stats) ) {
	if( ! inGlobal( t@scope ) ) {
		t@message = error( constraintError(), "testcase declaration is constrained to the global scope", t@location );
	}
	return t;
}