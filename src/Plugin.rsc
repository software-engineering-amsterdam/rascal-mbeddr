module Plugin

import lang::mbeddr::C;
import ParseTree;
import util::IDE;

private str LANG = "MBeddr";
private str EXT = "mbdr";

void main() {
  registerLanguage(LANG, EXT, start[TranslationUnit](str src, loc l) {
    return parse(#start[TranslationUnit], src, l);
  });
}