module typing::SymbolTable

alias SymbolTableRow = tuple[Type \type,str scope,bool initialized];
alias SymbolTable = map[ str, SymbolTableRow ];

data RuntimeException = TypeCheckerError( str message, node astNode );

public SymbolTable store( SymbolTable table, str name, SymbolTableRow row, node astNode ) {
	if( name in table && table[ name ].scope == row.scope ) {
		item = table[ name ];
		
		if( item.initialized ) {
			throw TypeCheckerError( "redefinition of \'<name>\'", astNode );
		} else if( item.\type != row.\type ) {
			throw TypeCheckerError( "redefinition of \'<name>\' with a different type \'<delAnnotations( row.\type )>\' vs \'<delAnnotations( table[name].\type )>\'", astNode );
		} else if( row.initialized ) {
			// Name already exists as an unitialized variable
			return table[ name ].initialized = true;
		}
	} else {
		return table[ name ] = row;
	} 
}

public SymbolTableRow lookup( SymbolTable table, str name ) {
	if( name in table ) {
		return table[ name ];
	}
}
