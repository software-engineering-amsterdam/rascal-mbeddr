module Plugin

import lang::mbeddr::MBeddrC;
import ParseTree;
import util::IDE;
import util::Editors;
import lang::mbeddr::AST;
import lang::mbeddr::ToC;
import IO;

private str LANG = "MBeddr";
private str EXT = "mbdr";

void main() {
  registerLanguage(LANG, EXT, start[Module](str src, loc l) {
    return parse(#start[Module], src, l);
  });
  
  registerContributions(LANG, {
     popup(
       menu("MBeddr", [
        action("Show C", void (Tree tree, loc selection) {
            println("Showing C...");
            if (start[Module] m := tree) {
              ast = implode(#lang::mbeddr::AST::Module, m);
              src = module2c(ast);
              out = m@\loc[extension="c"];
              writeFile(out, src);
              edit(out, []);
            }        
        })]))
  });
}