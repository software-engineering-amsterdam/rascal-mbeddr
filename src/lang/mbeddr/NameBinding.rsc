module lang::mbeddr::NameBinding

import lang::mbeddr::AST;
import util::Binder;

/*

Scopes:

- modules
- functions
- structs
- blocks

Names

- consts (TODO: #const)
- vardecls
- typedefs
- structs
- unions
- functions
- parameters
- struct fields
- enums
- enum constants
- labels


*/

/*
alias Binder = tuple[
  Scope(Scope) newScope,
  void(Scope, str, loc) \import, // todo: namespaces
  void(Scope, str, loc) \refer, 
  void(Scope, str, loc, Scope) \declare,
  */

ScopeGraph bind(Module m) {
  Binder b = newBinder();

  top-down visit(m) {
    case \module(n, _, _): {
      s = b.newScope(null());
       s2 = newScope(s);
  declare(s, x, s2);
  bind(ds, s2);  
    }
  }

}

void bind(\module(n, imps, ds), Scope p, Binder b) {
  s = b.newScope(p);
  b.declare(p, n, s);
  
  for (i <- imps) {
    bind(i, s, b);
  }
  
  for (d <- ds) {
    bind(d, s, b);
  } 
}

loc idOf(Id x) = x@location;

void bind(\import(ids), Scope s) {
  b.\import(s, xs[-1].name, xs[-1]@location);
  
  for (x <- xs[..-1]) {
    b.refer(s, x.name, x@location);
    s = b.newScope(s);
    b.\import(s, x.name, x@location);
  }
  
  b.refer(s, xs[-1].name, xs[-1]@location);
}


