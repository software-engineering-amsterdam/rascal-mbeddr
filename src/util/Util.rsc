module util::Util

import Node;

import lang::mbeddr::AST;

public str joinList( list[&T] l, str c ) = ( "" | it + e + c | e <- l )[0..-1];

public list[Type] parameterTypes( list[Param] params ) = [ paramType | param( _, paramType, _ ) <- params ];

public &T <: node copyAnnotations( &T <: node n, &T <: node m ) {
	return setAnnotations( n, getAnnotations( n ) + getAnnotations( m ) );
}

public str typeToString( Type t ) {
	switch( t ) {
		case id(id(name)) : return "<name>";
		case \void() : return "void";
		case int8() : return "int8";
		case int16() : return "int16";
		case int32() : return "int32";
		case int64() : return "int64";
		case uint8() : return "uint8";
		case uint16() : return "uint16";
		case uint32() : return "uint32";
		case uint64() : return "uint64";
		case \char() : return "char";
		case \boolean() : return "boolean";
		case \float() : return "float";
		case \double() : return "double";
		case struct(id(name)) : return "struct <name>";
		case struct(id(name), _) : return "struct <name>";
		case struct(_) : return "struct";
		case union(id(name)) : return "union <name>";
		case union(id(name), _) : return "union <name>";
		case union(list[Field] fields) : return "";
		case enum(id(name)) : return "enum <name>";
		case enum(id(name), _) : return "enum <name>";
		case enum(_) : return "enum";
		case array(Type \type) : return "array <typeToString(\type)>";
		case array(Type \type, int dim) : return "array[<dim>] <typeToString(\type)>";
		case pointer(Type \type) : return "pointer <typeToString(\type)>";
		case function(Type returnType, list[Type] args) : return "(<("" | it + "," + typeToString(arg) | arg <- args )>)=\>(<typeToString(returnType)>)";
  }
  
  return "";
}

&T <: node delAnnotationRec( &T <: node root, list[str] annoKeys ) {
	for( annoKey <- annoKeys ) {
		root = delAnnotationRec( root, annoKey );
	}
	
	return root;
}

&T <: node delAnnotationRec( &T <: node root, str annoKey ) {
	return visit( root ) {
		case node n => delAnnotation( n, annoKey )
	}
}