module core::typing::TypeTree

import IO;

import lang::mbeddr::AST;

public alias TypeTree = lrel[ Type \type, Type child ];

data Type = number();

private  TypeTree typeTree = [
	<\char(), \char()>,
    <\boolean(),  \boolean()>,
    <\float(),   \float()>,
    <\double(),   \double()>
];

private TypeTree Integers = [
	<int8(),    int16()>,
	<int16(),   int32()>,
    <int32(),   int64()>,
    
    <uint8(),   int16()>,
    <uint16(),  int32()>,
    <uint32(),  int64()>,
   
   	<usint8(),  uint8()>,
   	<usint8(),  int8()>,
   	<usint16(),  uint16()>,
   	<usint16(),  int16()>,
   	<usint32(),  uint32()>,
   	<usint32(),  int32()>,
   	<usint64(),  uint64()>,
   	<usint64(),  int64()>,
   	
   	<uint8(), usint8()>,
   	<uint16(), usint16()>,
   	<uint32(), usint32()>,
   	<uint64(), usint64()>,
   	
   	<int8(), usint8()>,
   	<int16(), usint16()>,
   	<int32(), usint32()>,
   	<int64(), usint64()>
];

private TypeTree Equality = [
	<\boolean(),\double()>,
	<\double(),\boolean()>
];

private lrel[ Type \type, list[Type] children ] Numbers = [
	< number(), [usint8(), float(), double(), \char()] >
];

private TypeTree Char2Int = [
	<int8(), char()>,
	<char(), int8()>
];

private TypeTree Int2Decimal = [
	<\uint64(), \float()>,
	<\float(), \double()>
];

private TypeTree Decimal2Int = [
	<\float(), \int8()>,
	<\double(), \float()>
];

private lrel[ &T, &T ] flatten( lrel[ &T column, list[&T] row ] lr ) {
	lrel[ &T, &T ] result = [];
	
	for( selector <- lr.column ) {	
		for( items <- lr[selector], item <- items ) {
			result += < selector, item >;
		}
	}
	
	return result;
}

public TypeTree CIntegerTypeTree = ( typeTree + Integers )+;
public TypeTree CTypeTree = ( CIntegerTypeTree + flatten( Numbers ) + Char2Int + Int2Decimal )+;
public TypeTree COrderedTypeTree = ( CTypeTree + Decimal2Int )+;
public TypeTree CEqualityTypeTree = ( COrderedTypeTree + Equality )+;

public bool inTypeTree( TypeTree tree, Type x, Type y ) = x in tree[ y ] || x == y;

