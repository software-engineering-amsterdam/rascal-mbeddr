module util::Binder

alias ScopeGraph = map[int, Scope];

alias Binder = tuple[
  Scope(Scope) newScope,
  void(Scope, str, loc) \import, // todo: namespaces
  void(Scope, str, loc) \refer, 
  void(Scope, str, loc, Scope) \declare,
  ScopeGraph scopeGraph
];

data Scope 
  = null() 
  | scope(list[Decl] decls, list[Ref] refs, list[Import] imports)
  | scopeId(int id)
  ;

Binder newBinder() {
  int id = 0;
  ScopeGraph scopes = ();
  
  Scope newScope(Scope parent) {
    s = scope([], [], []);
    scopes[id] = s;
    r = scopeId(id);
    id += 1;
    return r;
  }
  
  void \import(Scope s, str x, loc l) {
    scopes[s.id].imports += [<x, l>];
  }
  
  void refer(Scope s, str x, loc l) {
    scopes[s.id].refs += [<x, l>];
  } 
  
  void declare(Scope s, str x, loc l, Scope s2) {
    scopes[s.id].decls += [<x, l, s2>]; 
  }
  
  ScopeGraph scopeGraph() = scopes;
  
  return <newScope, \import, refer, declare, scopeGraph>;
}
