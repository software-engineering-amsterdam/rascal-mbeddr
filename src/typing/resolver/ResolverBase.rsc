module typing::resolver::ResolverBase

import ext::List;
import ext::Node;
import IO;
import Message;

import lang::mbeddr::AST;

import typing::IndexTable;
import typing::TypeTree;
import typing::Scope;
import typing::Util;

anno Type Expr @ \type;

data Type = empty();

bool isEmpty( Type t ) {
	e = empty();
	return e := t;
}

Type getType( Expr n ) {
	if( "type" in getAnnotations( n ) ) {
		return n@\type;
	} else {
		return empty();
	}
}