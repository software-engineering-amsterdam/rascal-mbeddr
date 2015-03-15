module typing::IndexTable

import IO;
import Node;
import Message;

import util::Util;
import lang::mbeddr::AST;
import typing::Util;

data DeclType 
	= enum() 
	| typedef() 
	| struct()
	| union()
	;

data Scope 
	= global( )
	| function( Scope scope )
	| block( Scope scope )
	| \switch( Scope scope )
	;
	
data SymbolTableRow 
	= symbolRow( Type \type, Scope scope, bool initialized )
	| symbolRow( SymbolTable symbols, Type \type, Scope scope, bool initialized )
	;

//alias SymbolTableRow = tuple[ Type \type, Scope scope, bool initialized ];
alias SymbolTable = map[ str, SymbolTableRow ];

alias TypeTableRow = tuple[Type \type, Scope scope, bool initialized ];
alias TypeTable = map[ tuple[str,DeclType], TypeTableRow ];

alias IndexTables = tuple[ SymbolTable symbols, TypeTable types ];

data RuntimeException = TypeCheckerError( str message, loc location );

anno SymbolTable node @ symboltable;
anno TypeTable node @ typetable;

anno Message Module@message;
anno Message Import@message;
anno Message QId@message;
anno Message Id@message;
anno Message Decl@message;
anno Message Stat@message;
anno Message Expr@message;
anno Message Param@message;
anno Message Literal@message;
anno Message Type@message;
anno Message Modifier@message;
anno Message Field@message;
anno Message Enum@message;

anno Scope Module@scope;
anno Scope Import@scope;
anno Scope QId@scope;
anno Scope Id@scope;
anno Scope Decl@scope;
anno Scope Stat@scope;
anno Scope Expr@scope;
anno Scope Param@scope;
anno Scope Literal@scope;
anno Scope Type@scope;
anno Scope Modifier@scope;
anno Scope Field@scope;
anno Scope Enum@scope;

tuple[ IndexTables tables, str errorMsg ]
store( IndexTables tables, 
	   str name, 
	   tuple[ Type \type, Scope scope, bool initialized ] row
	  ) {
	
	table = tables.symbols;
	types = tables.types;
	
	str errorMsg = "";
	
	if( name in table && table[ name ].scope == row.scope ) {
		item = table[ name ];
		
		if( item.initialized ) {
			errorMsg = "redefinition of \'<name>\'";
		} else if( item.\type != row.\type ) {
			errorMsg = "redefinition of \'<name>\' with a different type \'<typeToString( row.\type )>\' vs \'<typeToString( table[name].\type )>\'";
		} else if( row.initialized ) {
			table[ name ].initialized = true;
		}
		
	} else if( name in table && function(_,_) := row.\type && function(_,_) := table[ name ].\type && row.\type != table[ name ].\type ) {
		
		errorMsg = "confliciting types for \'<name>\'";
	
	} else {
		
		// Custom type
		if( id( id( typeName ) ) := row.\type && !doesTypeExist( types, typeName ) ) {
			errorMsg = "unknown type name \'<typeName>\'";
		} 
		
		// Struct type
		if( struct( id( structName ) ) := row.\type && !doesStructExist( types, structName ) ) {
			errorMsg = "unkown struct \'<structName>\'";
		}
		
		// Enum type
		if( enum( id( enumName ) ) := row.\type && !doesEnumExist( types, enumName ) ) {
			errorMsg = "unkown enum \'<enumName>\'";
		}
		
		table[ name ] = symbolRow( row.\type, row.scope, row.initialized );
	
	}
	
	return < < table, types >, errorMsg >;
	 
}

SymbolTable update( SymbolTable symbols, str name, SymbolTableRow row ) {
	if( name in symbols ) {
		symbols[ name ] = row;
	}
	
	return symbols;
} 

SymbolTableRow lookup( SymbolTable table, str name ) {
	if( name in table ) {
		return table[ name ];
	}
}

tuple[ IndexTables tables, str errorMsg ]
store( IndexTables tables, 
       tuple[str name,DeclType declType] key, 
       TypeTableRow row
      ) {
    errorMsg = "";  
     
	if( key in tables.types && 
		tables.types[key].scope == row.scope && 
		tables.types[key].initialized
		) {
		errorMsg = "redefinition of \'<key.name>\'";
	} else {
		tables.types[key] = row;
	}
	
	return < tables, errorMsg >;
}

bool doesTypeExist( TypeTable types, str name ) {
	return <name,typedef()> in types;
}

bool doesStructExist( TypeTable types, str name ) {
	return <name,struct()> in types;
}

bool doesEnumExist( TypeTable types, str name ) {
	return <name,enum()> in types;
}