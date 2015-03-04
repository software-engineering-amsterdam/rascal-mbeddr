module typing::\test::Scope

import typing::Scope;

public test bool test_sameFunctionScope() {

	return 
		sameFunctionScope( function(global()), function(global()) ) &&
		!sameFunctionScope( global(), function(global()) ) &&
		sameFunctionScope( function(block(function(global()))), block(function(block(function(global())))) );

}