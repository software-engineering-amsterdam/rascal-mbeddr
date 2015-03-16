module typing::constraints::Helper

import lang::mbeddr::AST;

Module constraints( Module m ) {
	return visit( m ) {
		case &T <: node n => constraint( n )
	}
}
