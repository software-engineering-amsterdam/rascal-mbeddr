@license{
  Copyright (c) 2009-2015 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Tijs van der Storm - storm@cwi.nl}
module lang::mbeddr::AST

data Module
  = \module(QId name, list[Import] imports, list[Decl] decls);

data Import
  = \import(QId name);
  
data QId
  = qid(list[Id] parts);

data Decl
  = function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Decl] decls, list[Stat] stats) 
  | function(list[Modifier] mods, Type \type, Id name, list[Param] params)
  | typeDef(list[Modifier] mods, Type \type, Id name)
  | struct(list[Modifier] mods, Id name) 
  | struct(list[Modifier] mods, Id name, list[Field] structDecls) 
  | union(list[Modifier] mods, Id name) 
  | union(list[Modifier] mods, Id name, list[Field] structDecls) 
  | enum(list[Modifier] mods, Id name) 
  | enum(list[Modifier] mods, Id name, list[Enum] enums)
  | variable(list[Modifier] mods, Type \type, Id name)
  | variable(list[Modifier] mods, Type \type, Id name, Expr init)
  ;

data Param
  = param(list[Modifier] mods, Type \type, Id name)
  ;

data Stat
  = block(list[Decl] decls, list[Stat] stats)
  | labeled(Id label, Stat stat)
  | \case(Expr guard, Stat body)
  | \default(Stat body)
  | semi()
  | expr(Expr expr)
  | ifThen(Expr cond, Stat body)
  | ifThenElse(Expr cond, Stat body)
  | \switch(Expr cond, Stat body)
  | \while(Expr cond, Stat body)
  | doWhile(Stat body, Expr cond)
  | \for(list[Expr] init, list[Expr] conds, list[Expr] update)
  | goto(Id label)
  | \continue()
  | \break()
  | \return()
  | \returnExpr(Expr expr)
  ;

data Literal
  = hex(str val)
  | \int(str val)
  | char(str val)
  | float(str val)
  | string(str val)
  ;

data Expr 
  = var(Id id)
  | lit(Literal lit)
  | subscript(Expr array, Expr sub)
  | call(Expr func, list[Expr] args)
  | sizeof(Type \type)
  | field(Expr record, Id name)
  | ptrField(Expr record, Id name)
  | postIncr(Expr arg)
  | postDecr(Expr arg)
  | preIncr(Expr arg)
  | preDecr(Expr arg)
  | addrOf(Expr arg)
  | refOf(Expr arg)
  | pos(Expr arg)
  | neg(Expr arg)
  | bitNot(Expr arg)
  | not(Expr arg)
  | sizeOfExpr(Expr arg)
  | cast(Type \type, Expr arg)
  | mul(Expr lhs, Expr rhs)
  | div(Expr lhs, Expr rhs)
  | \mod(Expr lhs, Expr rhs)
  | add(Expr lhs, Expr rhs)
  | sub(Expr lhs, Expr rhs)
  | shl(Expr lhs, Expr rhs)
  | shr(Expr lhs, Expr rhs)
  | lt(Expr lhs, Expr rhs)
  | gt(Expr lhs, Expr rhs)
  | leq(Expr lhs, Expr rhs)
  | geq(Expr lhs, Expr rhs)
  | eq(Expr lhs, Expr rhs)
  | neq(Expr lhs, Expr rhs)
  | bitAnd(Expr lhs, Expr rhs)
  | bitXor(Expr lhs, Expr rhs)
  | bitOr(Expr lhs, Expr rhs)
  | and(Expr lhs, Expr rhs)
  | or(Expr lhs, Expr rhs)
  | cond(Expr cond, Expr then, Expr els)
  | assign(Expr lhs, Expr rhs)
  | mulAssign(Expr lhs, Expr rhs)
  | divAssign(Expr lhs, Expr rhs)
  | modAssign(Expr lhs, Expr rhs)
  | addAssign(Expr lhs, Expr rhs)
  | subAssign(Expr lhs, Expr rhs)
  | shlAssign(Expr lhs, Expr rhs)
  | shrAssign(Expr lhs, Expr rhs)
  | bitAndAssign(Expr lhs, Expr rhs)
  | bitXorAssign(Expr lhs, Expr rhs)
  | bitOrAssign(Expr lhs, Expr rhs)
  ;  
  
  
data Id
  = id(str name)
  ; 
  
data Type 
  = id(Id name)
  | \void() 
  | int8()
  | int16()
  | int32()
  | int64()
  | uint8()
  | uint16()
  | uint32()
  | uint64()
  | \boolean()
  | \float() 
  | \double() 
  | struct(Id name) 
  | struct(Id name, list[Field] fields) 
  | struct(list[Field] fields) 
  | union(Id name) 
  | union(Id name, list[Field] fields) 
  | union(list[Field] fields) 
  | enum(Id name) 
  | enum(Id name, list[Enum] enums) 
  | enum(list[Enum] enums)
  | array(Type \type)
  | array(Type \type, int dim)
  | pointer(Type \type)
  | function(Type returnType, list[Type] args)
  ; 

data Modifier
  = const() 
  | volatile()
  | extern() 
  | static() 
  | auto() 
  | register()
  | exported()
  | static()
  ;
  
data Field
  = field(Type \type, Id name)
  ;
  
data Enum
  = const(Id name)
  | const(Id name, Expr init)
  ;