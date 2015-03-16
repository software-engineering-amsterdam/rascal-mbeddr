module typing::constraints::Helper

import IO;

import lang::mbeddr::AST;

Module constraints( Module m ) {
	return visit( m ) {
		case &T <: node n : {
		 insert constraint( n );
		}
	}
}
