module typing::Util

import ext::Node;

import lang::mbeddr::AST;

public default str typeToString( Type t ) = getName( t );

public str typeToString( id(id(name)) ) =  "<name>";
public str typeToString( struct(id(name)) ) =  "struct <name>";
public str typeToString( struct(id(name), _) ) =  "struct <name>";
public str typeToString( union(id(name)) ) =  "union <name>";
public str typeToString( union(id(name), _) ) =  "union <name>";
public str typeToString( union(list[Field] fields) ) =  "";
public str typeToString( enum(id(name)) ) =  "enum <name>";
public str typeToString( enum(id(name), _) ) =  "enum <name>";
public str typeToString( array(Type \type) ) =  "array <typeToString(\type)>";
public str typeToString( array(Type \type, int dim) ) =  "array[<dim>] <typeToString(\type)>";
public str typeToString( pointer(Type \type) ) =  "pointer <typeToString(\type)>";
public str typeToString( function(Type returnType, list[Type] args) ) =  "(<("" | it + "," + typeToString(arg) | arg <- args )>)=\>(<typeToString(returnType)>)";

public str litToString( Literal l ) = getName( l );