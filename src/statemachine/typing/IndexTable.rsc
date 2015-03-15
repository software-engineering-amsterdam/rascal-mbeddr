module statemachine::typing::IndexTable
extend typing::IndexTable;

import statemachine::AST;

anno Message StateMachineStat@message;
anno Message StateStat@message;

anno Scope StateMachineStat@scope;
anno Scope StateStat@scope;