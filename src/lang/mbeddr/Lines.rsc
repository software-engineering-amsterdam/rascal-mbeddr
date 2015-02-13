module lang::mbeddr::Lines

import lang::mbeddr::AST;

data Stat
  = line(int lineNo, str file);
  
Module insertLineDirectives(Module m) {
  return visit (m) {
    case list[Stat] ss =>
       [ line(s@location.begin.line, s@location.path), s | s <- ss]
  };
}