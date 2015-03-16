module lang::mbeddr::ToC

import lang::mbeddr::AST;
import util::SimpleBox;
import List;
import Node;
import IO;

// TODO: move */[] from types to names?
// TODO: separate header & c file.

str module2c(Module m) { 
	m = moduleC( m );
	
	return format(toCBox(m)); 
}

str module2h( Module m ) {
	m = moduleH( m );
	
	return format( toHBox( m ) );
}

private Module moduleH( Module m ) {
	hDecls = headerDecls( m );
	
	QId name = toHName( m.name );
	return \module( name, m.imports, hDecls );
}

private Module moduleC( Module m ) {
	hDecls = headerDecls( m );
	m.decls = m.decls - hDecls;
	
	return m;
}

private list[Decl] headerDecls( Module m ) {
	result = [];
	
	visit( m ) {
		case Decl d : {
			if( "header" in getAnnotations( d ) && d@header ) {
				result += d;
			}
		}
	}
	
	return result;
}

Box toCBox(\module(QId name, list[Import] imports, list[Decl] decls))
	= V(
		H(L("#include"), L(toCName(toHName(name))), hs=1),
		V([ toBox(i) | Import i <- imports ]),
		V([ toBox(d) | d <- decls ], vs=2)	
	);

Box toHBox(\module(QId name, list[Import] imports, list[Decl] decls))
  = V(
     H(L("#ifndef"), L(toCName(name)), hs=1),
     H(L("#define"), L(toCName(name)), hs=1),
     V([ toBox(i) | Import i <- imports ]),
     V([ toBox(d) | d <- decls ], vs=2),
     H(L("#endif"))
   ); 

Box toBox(\import(n))
  = H(L("#include"), H(L("\<"), L(toPath(n)), L(".h"), L("\>")), hs=1); 

QId toHName(qid(ids)) = qid( ids[0..-1] + id("<ids[-1].name>_H") );
str toCName(qid(ids)) = intercalate("_", [ i.name | Id i <- ids ]);

str toPath(qid(ids)) = intercalate("/", [ i.name | Id i <- ids ]); 



//list[Box] hsep(str sep, []) = [];
//list[Box] hsep(str sep, [x]) = [toBox(x)];
//list[Box] hsep(str sep, [x, y]) = [toBox(x), H(sep), toBox(y)];
//list[Box] hsep(str sep, list[Expr] xs) = [toBox(xs[0]), H(sep)] + hsep(sep, [xs[1]] + xs[2..])
//  when size(xs) > 2;

list[Box] hsep(str sep, list[Expr] xs) {
  if (xs == []) {
    return [];
  }

  bs = for (x <- xs) {
      append L(sep);
      append toBox(x);       
  } 
  
  return bs[1..];
}

Box pH(Box xs..., int hs = 0) = H([L("(")] + xs + [L(")")]);

/*
 * Expressions
 */

Box toBox(var(Id id)) = L(id.name);
Box toBox(lit(string(val))) = L("\"<val>\"");
Box toBox(lit(Literal lit)) = L(lit.val);

Box exprs2Box(list[Expr] exprs)
  = H(hsep(", ", exprs));

Box toBox(subscript(Expr array, Expr sub)) 
  = pH(toBox(array), L("["), toBox(sub), L("]"));

Box toBox(call(Expr func, list[Expr] args)) 
  = pH([L("("), *toBox(func), L(")"), L("("), exprs2Box(args), L(")")]);
  
Box toBox(sizeof(Type \type)) 
  = pH(L("("), pH(L("sizeof"), toBox(\type), hs=1), L(")"));

Box toBox(dotField(Expr record, Id name)) 
  = pH(toBox(record), L("."), L(name.name));
  
Box toBox(ptrField(Expr record, Id name)) 
  = pH(toBox(record), L("-\>"), L(name.name));

Box toBox(postIncr(Expr arg)) 
  = pH(toBox(arg), L("++"));
  
Box toBox(postDecr(Expr arg))
  = pH(toBox(arg), L("--"));

Box toBox(preIncr(Expr arg))
  = pH(L("++"), toBox(arg));

Box toBox(preDecr(Expr arg))
  = pH(L("--"), toBox(arg));

Box toBox(addrOf(Expr arg)) 
  = pH(L("&"), toBox(arg));
  
Box toBox(refOf(Expr arg))
  = pH(L("*"), toBox(arg));
  
Box toBox(pos(Expr arg))
  = pH(L("+"), toBox(arg));

Box toBox(neg(Expr arg))
  = pH(L("-"), toBox(arg));

Box toBox(bitNot(Expr arg))
  = pH(L("~"), toBox(arg));

Box toBox(not(Expr arg))
  = pH(L("!"), toBox(arg));

Box toBox(sizeOfExpr(Expr arg)) 
  = pH(L("sizeof("), toBox(arg), L(")"));
  
Box toBox(cast(Type \type, Expr arg)) 
  = pH(L("("), toBox(\type), L(")"), toBox(arg));
  
Box toBox(mul(Expr lhs, Expr rhs)) 
  = pH(toBox(lhs), L("*"), toBox(rhs), hs=1);
  
Box toBox(div(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("/"), toBox(rhs), hs=1);

Box toBox(\mod(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("%"), toBox(rhs), hs=1);

Box toBox(add(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("+"), toBox(rhs), hs=1);

Box toBox(sub(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("-"), toBox(rhs), hs=1);

Box toBox(shl(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\<\<"), toBox(rhs), hs=1);

Box toBox(shr(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\>\>"), toBox(rhs), hs=1);

Box toBox(lt(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\<"), toBox(rhs), hs=1);

Box toBox(gt(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\>"), toBox(rhs), hs=1);

Box toBox(leq(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\<="), toBox(rhs), hs=1);

Box toBox(geq(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\>="), toBox(rhs), hs=1);

Box toBox(eq(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("=="), toBox(rhs), hs=1);

Box toBox(neq(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("!="), toBox(rhs), hs=1);

Box toBox(bitAnd(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("&"), toBox(rhs), hs=1);

Box toBox(bitXor(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("^"), toBox(rhs), hs=1);

Box toBox(bitOr(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("|"), toBox(rhs), hs=1);

Box toBox(and(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("&&"), toBox(rhs), hs=1);

Box toBox(or(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("||"), toBox(rhs), hs=1);

Box toBox(cond(Expr cond, Expr then, Expr els))
  = pH(toBox(cond), L("?"), toBox(then), L(":"), toBox(els), hs=1);


Box toBox(assign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("="), toBox(rhs), hs=1);

Box toBox(mulAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("*="), toBox(rhs), hs=1);

Box toBox(divAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("/="), toBox(rhs), hs=1);

Box toBox(modAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("%="), toBox(rhs), hs=1);

Box toBox(addAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("+="), toBox(rhs), hs=1);

Box toBox(subAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("-="), toBox(rhs), hs=1);

Box toBox(shlAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\<\<="), toBox(rhs), hs=1);

Box toBox(shrAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("\>\>="), toBox(rhs), hs=1);

Box toBox(bitAndAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("&="), toBox(rhs), hs=1);

Box toBox(bitXorAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("^="), toBox(rhs), hs=1);

Box toBox(bitOrAssign(Expr lhs, Expr rhs))
  = pH(toBox(lhs), L("|="), toBox(rhs), hs=1);

  
/*
 * Declarations 
 */  
 
 
Box hEmptyPrefix(list[&T] ts, Box(list[&T]) tb, Box bs..., int hs=0)
  = H(tb(ts) + bs, hs = hs)
  when size(ts) > 0;

Box hEmptyPrefix(list[&T] ts, Box(list[&T]) tb, Box bs..., int hs=0)
  = H(bs, hs = hs)
  when size(ts) == 0;
  
Box mods2Box(list[Modifier] mods) = H([ L(getName(m)) | m <- mods], hs=1);  

Box params2box(list[Param] ps) = H([ H(param2Box(p), L(",")) | p <- ps ]);

Box param2Box(param(list[Modifier] mods, Type \type, Id name))
  = hEmptyPrefix(mods, mods2Box, toBox(\type), L(name.name), hs=1);

default void toBox( &T <: node n ) = println( "unkown node: <n>" ); 

Box toBox(Decl::preProcessor(str input)) = L( input );

Box toBox(Decl::function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats))
  = V(
      hEmptyPrefix(mods, mods2Box, toBox(\type), H(L(name.name), L("("), params2box(params), L(")")), L("{"), hs=1),
      I([ toBox(s) | s <- stats ]),
      L("}")
    ); 
  
Box toBox(Decl::function(list[Modifier] mods, Type \type, Id name, list[Param] params))
  = hEmptyPrefix(mods, mods2Box, toBox(\type), H(L(name.name), L("("), params2box(params), H(L(")"), L(";"))), hs=1);


Box toBox(typeDef(list[Modifier] mods, Type \type, Id name))
  = hEmptyPrefix(mods, mods2Box, L("typedef"), toBox(\type), H(L(name.name), L(";")), hs=1); 
  
Box toBox(Decl::struct(list[Modifier] mods, Id name, list[Field] fields)) 
  = V(
       hEmptyPrefix(mods, mods2Box, L("struct"), L(name.name), L("{"), hs=1),
       I([ toBox(f) | f <- fields ]),
       L("}")
    ); 
  
Box toBox(Decl::struct(list[Modifier] mods, Id name)) 
  = hEmptyPrefix(mods, mods2Box, L("struct"), H(L(name.name), L(";")), hs=1);

Box toBox(Decl::union(list[Modifier] mods, Id name, list[Field] fields)) 
  = V(
       hEmptyPrefix(mods, mods2Box, L("union"), L(name.name), L("{"), hs=1),
       I([ toBox(f) | f <- fields ]),
       L("}")
    ); 
 
Box toBox(Decl::union(list[Modifier] mods, Id name))
  = hEmptyPrefix(mods, mods2Box, L("union"), H(L(name.name), L(";")), hs=1);
   
Box toBox(Decl::enum(list[Modifier] mods, Id name, list[Enum] enums))
  = V(
       hEmptyPrefix(mods, mods2Box, L("enum"), L(name.name), L("{"), hs=1),
       I([ toBox(e) | e <- enums ]),
       L("}")
    ); 

Box toBox(Decl::enum(list[Modifier] mods, Id name))
  = hEmptyPrefix(mods, mods2Box, L("enum"), H(L(name.name), L(";")), hs=1);
  
Box toBox(variable(list[Modifier] mods, Type \type, Id name))
  = hEmptyPrefix(mods, mods2Box, toBox(\type), H(L(name.name), L(";")), hs=1);


Box toBox(variable(list[Modifier] mods, Type \type, Id name, Expr init))
  = hEmptyPrefix(mods, mods2Box, toBox(\type), L(name.name), L("="), H(toBox(init), L(";")), hs=1);
 
 
Box toBox(Field::field(Type \type, Id name))
  = H(toBox(\type), H(L(name.name), L(";")), hs=1);
  
Box toBox(Enum::const(Id name))
  = H(L(name.name), L(";"));

Box toBox(Enum::const(Id name, Expr init))
  = H(L(name.name), L("="), H(toBox(init), L(";")), hs=1);

Box toBox(Decl::constant(Id name, Expr init))
  = H(L("#define"),L("="),H(L("("),toBox(init),L(")"),L(";")),hs=1);
 
/*
 * Statements
 */
 
Box stats2Box(list[Stat] stats) = V([ toBox(s) | s <- stats]);
 
Box toBox(block(list[Stat] stats)) = V(L("{"), I(stats2Box(stats)), L("}"));
Box toBox(decl(Decl decl)) = toBox(decl);

Box toBox(labeled(Id label, Stat stat)) = H(H(L(label.name), L(":")), toBox(stat), hs=1);
Box toBox(semi()) = L(";");
Box toBox(expr(Expr expr)) = H(toBox(expr), L(";"));

Box toBox(ifThen(Expr cond, Stat body)) = 
  V(
    H(L("if"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}")
  )
  when body is block;
  
Box toBox(ifThen(Expr cond, Stat body)) = 
  V(
    H(L("if"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(toBox(body)),
    L("}")
  )
  when !(body is block);
  
  
Box toBox(ifThenElse(Expr cond, Stat body, Stat els)) =
  V(
    H(L("if"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}"),
    H(L("else"), L("{"), hs=1),
    I(stats2Box(els.stats)),
    L("}")
  )
  when body is block, els is block;

Box toBox(ifThenElse(Expr cond, Stat body, Stat els)) =
  V(
    H(L("if"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(toBox(body)),
    L("}"),
    H(L("else"), L("{"), hs=1),
    I(stats2Box(els.stats)),
    L("}")
  )
  when !(body is block), els is block;

Box toBox(ifThenElse(Expr cond, Stat body, Stat els)) =
  V(
    H(L("if"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}"),
    H(L("else"), L("{"), hs=1),
    I(toBox(els)),
    L("}")
  )
  when body is block, !(els is block);

Box toBox(ifThenElse(Expr cond, Stat body, Stat els)) =
  V(
    H(L("if"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(toBox(body)),
    L("}"),
    H(L("else"), L("{"), hs=1),
    I(toBox(els)),
    L("}")
  )
  when !(body is block), !(els is block);


Box toBox(\while(Expr cond, Stat body)) = 
  V(
    H(L("while"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}")
  )
  when body is block;

Box toBox(\while(Expr cond, Stat body)) = 
  V(
    H(L("while"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(toBox(body)),
    L("}")
  )
  when !(body is block);


Box toBox(doWhile(Stat body, Expr cond)) = 
  V(
    H(L("do"), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}"),
    H(L("while"), H(L("("), toBox(cond), L(")"), L(";")), hs=1)
  )
  when body is block;

Box toBox(doWhile(Stat body, Expr cond)) = 
  V(
    H(L("do"), L("{"), hs=1),
    I(toBox(body)),
    L("}"),
    H(L("while"), H(L("("), toBox(cond), L(")"), L(";")), hs=1)
  )
  when !(body is block);


Box toBox(\for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body)) = 
  V(
    H(L("for"), H(L("("), exprs2Box(init), L(";")), H(exprs2Box(conds), L(";")), H(exprs2Box(update), L(")")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}")
  )
  when body is block;

Box toBox(\for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body)) = 
  V(
    H(L("for"), H(L("("), exprs2Box(init), L(";")), H(exprs2Box(conds), L(";")), H(exprs2Box(update), L(")")), L("{"), hs=1),
    I(toBox(body)),
    L("}")
  )
  when !(body is block);


Box toBox(goto(Id label)) = H(L("goto"), H(L(label.name), L(";")));
Box toBox(\continue()) = H(L("continue"), L(";"));
Box toBox(\break()) = H(L("break"), L(";"));
Box toBox(\return()) = H(L("return"), L(";"));
Box toBox(\returnExpr(Expr expr)) = H(L("return"), H(toBox(expr), L(";")), hs=1);


Box toBox(\switch(Expr cond, Stat body)) = 
  V(
    H(L("switch"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}")
  )
  when body is block;

Box toBox(\switch(Expr cond, Stat body)) = 
  V(
    H(L("switch"), H(L("("), toBox(cond), L(")")), L("{"), hs=1),
    I(toBox(body)),
    L("}")
  )
  when !(body is block);

Box toBox(\case(Expr guard, Stat body)) =
  V(
    H(L("case"), H(toBox(guard), L(":")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}")
  )
  when body is block;

Box toBox(\case(Expr guard, Stat body)) =
  V(
    H(L("case"), H(toBox(guard), L(":")), L("{"), hs=1),
    I(toBox(body)),
    L("}")
  )
  when !(body is block);
    
Box toBox(\default(Stat body)) = 
  V(
    H(H(L("default"), L(":")), L("{"), hs=1),
    I(stats2Box(body.stats)),
    L("}")
  )
  when body is block;

Box toBox(\default(Stat body)) = 
  V(
    H(H(L("default"), L(":")), L("{"), hs=1),
    I(toBox(body)),
    L("}")
  )
  when !(body is block);


Box toBox(line(int lineNo, str file)) 
  = H(L("#line"), H(L("<lineNo>"), L(",")), L("\"<file>\""), hs=1);
  
  
Box toBox(Type::id(Id name)) = L(name.name);
Box toBox(\void()) = L("void"); 
Box toBox(int8()) = L("int8_t");
Box toBox(int16()) = L("int16_t");
Box toBox(int32()) = L("int32_t");
Box toBox(int64()) = L("int64_t");
Box toBox(uint8()) = L("uint8_t");
Box toBox(uint16()) = L("uint16_t");
Box toBox(uint32()) = L("uint32_t");
Box toBox(uint64()) = L("uint64_t");
Box toBox(\boolean()) = L("bool");
Box toBox(Type::\float()) = L("float"); 
Box toBox(\double()) = L("double"); 
Box toBox(Type::struct(Id name)) = H(L("struct"), L(name.name), hs=1); 
Box toBox(Type::struct(Id name, list[Field] fields)) = 
  V(
    H(L("struct"), L(name.name), L("{"), hs=1),
     I(V([ toBox(f) | f <- fields ])),
    L("}")
  );
    
Box toBox(Type::struct(list[Field] fields)) = 
  V(
    H(L("struct"), L("{"), hs=1),
    I(V([ toBox(f) | f <- fields ])),
    L("}")
  );

Box toBox(Type::union(Id name)) = H(L("union"), L(name.name), hs=1);
 
Box toBox(Type::union(Id name, list[Field] fields)) =
  H(L("union"), L(name.name), L("{"), H([ H(toBox(f), L(";")) | f <- fields ], hs=1), L("}"));

Box toBox(Type::union(list[Field] fields)) =  
  H(L("union"), L("{"), H([ H(toBox(f), L(";")) | f <- fields ], hs=1), L("}"));

Box toBox(Type::enum(Id name)) = H(L("enum"), L(name.name), hs=1);
 
Box toBox(Type::enum(Id name, list[Enum] enums)) =
   H(L("enum"), L(name.name), L("{"), H([ H(toBox(e), L(";")) | e <- enums ], hs=1), L("}"));

Box toBox(Type::enum(list[Enum] enums)) =
   H(L("enum"), L("{"), H([ H(toBox(e), L(";")) | e <- enums ], hs=1), L("}"));

Box toBox(array(Type \type)) = H(toBox(\type), L("["), L("]"));
Box toBox(array(Type \type, int dim)) = H(toBox(\type), L("["), L("<dim>"), L("]"));
Box toBox(pointer(Type \type)) = H(toBox(\type), L("*"));

Box toBox(Type::function(Type returnType, list[Type] args)) = 
   H(toBox(returnType), L("("), H([ H(toBox(t), L(",")) | t <- args], hs=1), L(")"));

  