module statemachine::Syntax
extend lang::mbeddr::MBeddrC;

syntax Decl = stateMachine: Modifier* "statemachine" Id ("initial" "=" Id)? "{" StateMachineStat* "}";

syntax StateMachineStat 
	= state: "state" Id "{" StateStat* "}"
	| var: Modifier* "var" Type Id "=" Expr
	| inEvent: "in" "event" Id "(" {Param ","}* ")"
	;

syntax StateStat
	= on: "on" Id "[" Expr? "]" "-\>" Id
	| entry: "entry" "{" Stat* "}"
	| exit: "exit" "{" Stat* "}"
	;

syntax Modifier
	= readable: "readable"
	;