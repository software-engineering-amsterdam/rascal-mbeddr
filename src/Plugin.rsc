module Plugin

// LIBRARY IMPORTS
import IO;
import Message;
import Node;
import Map;
import ParseTree;
import util::IDE;
import util::Editors;

// LOCAL IMPORTS 
import Parser;
import TypeChecker;
import Desugar;
import lang::mbeddr::ToC;
import typing::IndexTable;
import util::Util;

private str LANG = "MBeddr";
private str EXT = "mbdr";

void main() {
  registerLanguage(LANG, EXT, start[Module](str src, loc l) {
    return parse( src, l );
  });
  
  registerContributions(LANG, {
     popup(
       menu("MBeddr", [
        action("Show C", convert2C)]
        )
      )
  });
  
  registerAnnotator(LANG, typeCheckerAnnotator); 
}

void printErrors( start[Module] m ) {
	visit( m ) {
		case Tree t : {
			if( "message" in getAnnotations(t) ) {
				println( t@message );
			}
		}
	}
}

void convert2C(Tree tree, loc selection) {
    println("Showing C...");
    if (start[Module] m := tree) {
      ast = createAST( m );
      ast = runTypeChecker( ast );
      
      if( !hasErrors( ast ) ) {
	      ast = desugarModule( ast );
	      
	      src = module2c(ast);
	      out = m@\loc[extension="c"];
	      
	      writeFile(|project://rascal-mbeddr/<out.path>|, src);
	      //edit(out, []);
	  }
    }        
}

start[Module] typeCheckerAnnotator( start[Module] m ) {
	ast = createAST( m );
	ast = runTypeChecker( ast );
	
	msgs = collectMessages( ast );
	
	return visit( m ) {
		case Tree t : { 
			if( msgs[t@\loc]? ) {
				msg = msgs[t@\loc];
				msgs = delete( msgs, t@\loc );
				insert t[@message=msg];
			}
		} 
	}
}