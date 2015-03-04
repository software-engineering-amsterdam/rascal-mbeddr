module statemachine::typing::Indexer
extend typing::Indexer;

import statemachine::AST;

import statemachine::typing::IndexTable;
import statemachine::typing::Scope;

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:stateMachine( list[Modifier] mods, id( name ), list[Id] initial, list[StateMachineStat] body ),
	   	 IndexTables tables, 
	   	 Scope scope
	   ) {

	storeResult = store( tables, name, < stateMachine(), scope, true > );
	d.body = indexer( body, storeResult.tables, stateMachine( scope ) );
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}