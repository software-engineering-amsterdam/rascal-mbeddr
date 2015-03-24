module extensions::statemachine::typing::IndexTable
extend typing::IndexTable;

import extensions::statemachine::AST;

anno Scope StateMachineStat@scope;
anno Scope StateStat@scope;

data IndexTableKey
	= objectKey( str name )
	;

data IndexTableRow
	= objectRow( IndexTable symbols )
	;
	
StoreResult store( IndexTable table, key:objectKey(_), row:objectRow(_) ) {
	errorMsg = "";
	
	if( key in table ) {
		errorMsg = "Object with name <key.name> already exists";
	} else {
		table[ key ] = row;
	}
	
	return < table, errorMsg >;
}

IndexTableRow lookup( IndexTable table, key:objectKey(_) ) {
	row = table[key];
	assert objectRow(_) := row : "Can only store \'objectRow\' under \'objectKey\'";
	return row;
}

bool lookup( IndexTable table, key:objectKey(_) ) {
	return key in table;
}

IndexTable update( IndexTable table, key:objectKey(_), row:objectRow(_) ) {
	if( key in table ) {
		table[ key ] = row;
	}
	return table;
}