module typing::\test::Indexer

import typing::\test::Helper;

import IO;
import List;

public test bool test_redefenition_1() {
	str input = "module Test;
				'char c = \'x\';
				'char c = \'y\';";
	msgs = indexer( input );
	
	return size( msgs ) == 1 &&
		   error( "redefinition of \'c\'", _ ) := msgs[0];
}

public test bool test_redefenition_2() {
	str input = "module Test;
				'char c;
				'char c = \'y\';";
	msgs = indexer( input );
	
	return size( msgs ) == 0;
}

public test bool test_redefenition_3() {
	str input = "module Test;
				'char c;
				'int8 c = 1;";
	msgs = indexer( input );
	
	return size( msgs ) == 1 &&
		   error( "redefinition of \'c\' with a different type \'int8\' vs \'char\'", _ ) := msgs[0];
}

public test bool test_custom_type() {
	str input = "module Test;
				'point c;";
	msgs = indexer( input );
	
	return size( msgs ) == 1 &&
		   error( "unknown type name \'point\'", _ ) := msgs[0];
}

public test bool test_struct() {
	str input = "module Test;
				'struct point c;";
	msgs = indexer( input );
	
	return size( msgs ) == 1 &&
		   error( "unkown struct \'point\'", _ ) := msgs[0];
}

public test bool test_enum() {
	str input = "module Test;
				'enum color c;";
	msgs = indexer( input );
	
	return size( msgs ) == 1 &&
		   error( "unkown enum \'color\'", _ ) := msgs[0];
}

public test bool test_scope() {
	str input = "module Test;
				'int8 x = 9;
				'void fun() {
				'	if( true ) {
				'		int8 x = 10;
				'	}
				'	int8 x = 11;
				'}";
	msgs = indexer( input );
	
	return size( msgs ) == 0;
}