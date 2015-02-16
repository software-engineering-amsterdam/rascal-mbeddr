module lang::mbeddr::Disamb

import lang::mbeddr::MBeddrC;
import ParseTree;
import Set;
import IO;

start[Module] disamb(start[Module] src) {
   env = {};
   
   return top-down visit (src) {
      case (Decl)`typedef <Type typ> <Id x>;`: {
         //println("Typedef <x>");
         env += {x};
      }
         
      case amb(alts): {
         //println("Amb");
         for ({a, *as} := alts) {
            //println("Alt: \'<a>\'");
            if ((Stat)`<Id x> * <Expr y>;` := a, x in env) {
              //println("Filtering");
              if (size(as) > 1) {
                return amb(as);
              }
              else {
                return getOneFrom(as);
              }
            }
         }
      }    
   };
}