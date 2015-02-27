module baseextensions::\test::tests

import Message;
import Node;

import Desugar;

import typechecker::IndexTable;
import baseextensions::AST;
import baseextensions::TypeChecker;

public loc nested_returns = |project://rascal-mbeddr/src/baseextensions/test/input/nested-returns.mbeddr|;

list[Message] findErrors( Module m ) {
	msgs = [];
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations(n) ) {
				msgs += n@message;
			}
		}
	}
	
	return msgs;
}

public test bool nestedReturns() {
	ast = createAST( nested_returns );
	ast = evaluator( createIndexTable( ast ) );
	
	msgs = findErrors( ast );
	
	return msgs == [];	
}