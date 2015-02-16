module Plugin

import lang::mbeddr::MBeddrC;
import ParseTree;
import util::IDE;

private str LANG = "MBeddr";
private str EXT = "mbdr";

void main() {
  registerLanguage(LANG, EXT, start[Module](str src, loc l) {
    return parse(#start[Module], src, l);
  });
}