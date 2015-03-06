module statemachine::typing::IndexTable
extend typing::IndexTable;

import Message;

import statemachine::AST;
import statemachine::typing::Scope;

anno Message StateMachineStat@message;
anno Message StateStat@message;

anno Scope StateMachineStat@scope;
anno Scope StateStat@scope;