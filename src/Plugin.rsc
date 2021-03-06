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
import typechecker::TypeChecker;
import Desugar;
import lang::mbeddr::ToC;
import core::typing::IndexTable;
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

void printLinks( start[Module] m ) {
	visit( m ) {
		case Tree t : {
			if( "link" in getAnnotations(t) ) {
				println( "<t@\loc> -\> <t@link>" );
			}
		}
	}
}

void convert2C( Tree tree ) = convert2C( tree, |tmp:///| );
void convert2C(Tree tree, loc selection) {
    println("Showing C...");
    if (start[Module] m := tree) {
      ast = createAST( m );
      ast = runTypeChecker( ast );
      
      if( !hasErrors( ast ) ) {
	      ast = desugarModule( ast );
	      
	      cSrc = module2c(ast);
	      hSrc = module2h(ast);
	      cOut = m@\loc[extension="c"];
	      hOut = m@\loc[extension="h"];
	      
	      writeFile(|project://rascal-mbeddr/<cOut.path>|, cSrc);
	      writeFile(|project://rascal-mbeddr/<hOut.path>|, hSrc);
	      //edit(out, []);
	  } else {
		println( "Found errors in input" );
	  }
    }        
}

start[Module] typeCheckerAnnotator( start[Module] m ) {
	ast = createAST( m );
	ast = runTypeChecker( ast );
	
	msgs = collectMessages( ast );
	links = collectLinks( ast );
	
	return visit( m ) {
		case Tree t : { 
			if( msgs[t@\loc]? ) {
				msg = msgs[t@\loc];
				msgs = delete( msgs, t@\loc );
				t@message = msg;
			}
			
			if( links[t@\loc]? ) {
				link = links[t@\loc];
				links = delete( links, t@\loc );
				t@link = link;
			}
			
			insert t;
		} 
	}
}