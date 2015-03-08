module statemachine::Syntax
extend lang::mbeddr::MBeddrC;

syntax Decl = stateMachine: Modifier* "statemachine" Id ("initial" "=" Id)? "{" StateMachineStat* "}";

syntax StateMachineStat 
	= state: "state" Id "{" StateStat* "}"
	| var: Modifier* "var" Type Id "=" Expr
	| inEvent: "in" "event" Id "(" {Param ","}* ")"
	| outEvent: "out" "event" Id "(" {Param ","}* ")" "=\>" Id
	;

syntax StateStat
	= on: "on" Id "[" Expr? "]" "-\>" Id
	| entry: "entry" "{" Stat* "}"
	| exit: "exit" "{" Stat* "}"
	;

syntax Stat
	= send: "send" Id "(" {Expr ","}* ")" ";"
	;

syntax Modifier
	= readable: "readable"
	;
	
keyword Keyword 
	= "send"
	;