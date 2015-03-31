module core::typing::Util

import util::Math;
import util::ext::List;
import util::ext::Node;

import IO;

import lang::mbeddr::AST;

public default str typeToString( Type t ) = getName( t );

public str typeToString( usint64() ) = "uint64 || int64";   
public str typeToString( usint8() ) = "uint8 || int8"; 
public str typeToString( usint16() ) = "uint16 || int16"; 
public str typeToString( usint32() ) = "uint32 || int32"; 
public str typeToString( usint64() ) = "uint64 || int64";
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

// Signed int8   => -128 to 127
// Unsigned uint8 => 0 to 255
public int detectLiteralBitSize( int v ) {
	v = v < 0 ? abs(v)*2 : abs(v) + 1;
	intSizes = [ 8, 16, 32, 64 ];
	bits = ceil( log( v, 2 ) );
	
	while( bits > intSizes[0] ) { intSizes = pop( intSizes )<1>; }
	return intSizes[0];
}

public default Type unsignedIntegerType( _ ) = usint64();  
public Type unsignedIntegerType( 8 ) = usint8();  
public Type unsignedIntegerType( 16 ) = usint16();  
public Type unsignedIntegerType( 32 ) = usint32();  
public Type unsignedIntegerType( 64 ) = usint64();

public default Type signedIntegerType( _ ) = int64();  
public Type signedIntegerType( 8 ) = int8();  
public Type signedIntegerType( 16 ) = int16();  
public Type signedIntegerType( 32 ) = int32();  
public Type signedIntegerType( 64 ) = int64();
  
