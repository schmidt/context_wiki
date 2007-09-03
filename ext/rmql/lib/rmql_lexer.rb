class RMQLLexer < Dhaka::CompiledLexer

  self.specification = RMQLLexerSpec

  start_with 19812160

  at_state(19717880) {
    accept("[<>=][<>=]?")
    for_characters("<", "=", ">") { switch_to 19796730 }
  }

  at_state(19747580) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
    for_characters("h") { switch_to 19747320 }
  }

  at_state(19755820) {
    for_characters("K", "V", "k", "v", "a", "A", "L", "W", "l", "w", "b", "B", "M", "X", "m", "x", "C", "N", "Y", "c", "n", "y", "D", "O", "Z", "d", "o", "z", "E", "P", "e", "p", "F", "Q", "f", "q", "G", "R", "g", "r", "h", "s", "H", "S", "I", "T", "i", "t", "J", "U", "j", "u") { switch_to 19755560 }
  }

  at_state(19788410) {
    for_characters("6", "7", "8", "9", "0", "1", "2", "3", "4", "_", "5") { switch_to 19788050 }
    for_characters(">") { switch_to 19785790 }
    for_characters("K", "V", "v", "k", "A", "W", "w", "a", "l", "L", "B", "b", "X", "x", "m", "M", "c", "N", "C", "y", "n", "Y", "Z", "z", "d", "o", "D", "O", "e", "E", "P", "p", "F", "q", "f", "Q", "g", "r", "G", "R", "S", "s", "h", "H", "T", "I", "t", "i", "j", "J", "U", "u") { switch_to 19788410 }
  }

  at_state(19793750) {
    accept("<[a-zA-Z]+[a-zA-Z0-9_]*>")
  }

  at_state(19785790) {
    accept("<\\/\\s?[a-zA-Z]+[a-zA-Z0-9_]*>")
  }

  at_state(19803890) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("r") { switch_to 19801910 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19811720) {
    accept("\\s+")
    for_characters(" ", "\r", "\t", "\n") { switch_to 19811720 }
  }

  at_state(19796730) {
    accept("[<>=][<>=]?")
  }

  at_state(19717260) {
    for_characters("K", "V", "k", "v", "l", "w", "a", "A", "L", "W", "b", "B", "M", "X", "m", "x", "C", "N", "Y", "c", "n", "y", "D", "O", "Z", "d", "o", "z", "E", "P", "e", "p", "F", "Q", "f", "q", "G", "R", "g", "r", "H", "S", "h", "s", "I", "T", "i", "t", "J", "U", "j", "u") { switch_to 19717000 }
  }

  at_state(19722620) {
    accept("or")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19788650) {
    for_characters(" ", "\r", "\t", "\n") { switch_to 19782650 }
    for_characters("v", "K", "k", "V", "l", "w", "W", "A", "L", "a", "x", "B", "X", "m", "b", "M", "n", "N", "C", "Y", "c", "y", "d", "D", "o", "O", "Z", "z", "e", "P", "E", "p", "f", "F", "Q", "q", "g", "G", "R", "r", "h", "H", "S", "s", "t", "T", "i", "I", "j", "U", "J", "u") { switch_to 19788410 }
  }

  at_state(19796090) {
    for_characters("K", "V", "6", "k", "v", "a", "A", "L", "W", "7", "l", "w", "b", "B", "M", "X", "8", "m", "x", "C", "N", "Y", "9", "c", "n", "y", "D", "O", "Z", "d", "o", "z", "E", "P", "0", "e", "p", "F", "Q", "1", "f", "q", "G", "R", "2", "g", "r", "H", "S", "3", "h", "s", "I", "T", "4", "i", "t", "_", "j", "u", "J", "U", "5") { switch_to 19796090 }
    for_characters(">") { switch_to 19793750 }
  }

  at_state(19796450) {
    for_characters("6", "7", "8", "9", "0", "1", "2", "3", "_", "4", "5") { switch_to 19796090 }
    for_characters("K", "v", "V", "k", "a", "w", "l", "W", "L", "A", "x", "X", "m", "M", "B", "b", "y", "n", "Y", "N", "c", "C", "z", "Z", "o", "O", "d", "D", "p", "e", "P", "E", "F", "q", "Q", "f", "r", "g", "R", "G", "s", "S", "h", "H", "t", "i", "T", "I", "u", "U", "j", "J") { switch_to 19796450 }
    for_characters(">") { switch_to 19793750 }
  }

  at_state(19709210) {
    accept("\\{")
  }

  at_state(19778120) {
    accept("\\}")
  }

  at_state(19717000) {
    accept("\\$[a-zA-Z]+[a-zA-Z0-9_]*")
    for_characters("v", "V", "k", "K", "a", "w", "W", "l", "L", "A", "x", "m", "X", "M", "B", "b", "y", "Y", "n", "c", "N", "C", "O", "d", "D", "z", "o", "Z", "p", "e", "P", "E", "q", "Q", "f", "F", "r", "R", "g", "G", "s", "h", "S", "H", "t", "T", "i", "I", "J", "u", "j", "U") { switch_to 19717000 }
    for_characters("6", "7", "8", "9", "0", "1", "2", "3", "4", "_", "5") { switch_to 19716630 }
  }

  at_state(19755560) {
    accept("\\/[a-zA-Z]+[a-zA-Z0-9_]*")
    for_characters("v", "V", "k", "K", "A", "a", "w", "l", "W", "L", "b", "x", "X", "m", "M", "B", "y", "n", "Y", "c", "N", "C", "z", "Z", "o", "O", "d", "D", "p", "e", "P", "E", "Q", "f", "F", "q", "r", "g", "R", "G", "s", "S", "h", "H", "t", "T", "i", "I", "u", "j", "U", "J") { switch_to 19755560 }
    for_characters("6", "7", "8", "9", "0", "1", "2", "3", "_", "4", "5") { switch_to 19755190 }
  }

  at_state(19777650) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("t") { switch_to 19777390 }
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19812160) {
    for_characters("\t", "\r", " ") { switch_to 19811720 }
    for_characters("o") { switch_to 19724600 }
    for_characters("a") { switch_to 19733780 }
    for_characters("w") { switch_to 19747580 }
    for_characters("=", ">") { switch_to 19717880 }
    for_characters("/") { switch_to 19755820 }
    for_characters("$") { switch_to 19717260 }
    for_characters("i") { switch_to 19761360 }
    for_characters("<") { switch_to 19797000 }
    for_characters(")") { switch_to 19747990 }
    for_characters("r") { switch_to 19777910 }
    for_characters("{") { switch_to 19709210 }
    for_characters("(") { switch_to 19709430 }
    for_characters("'") { switch_to 19717460 }
    for_characters("J", "8", "p", "9", "K", "q", "L", "M", "s", "N", "t", "O", "u", "P", "b", "Q", "c", "v", "R", "d", "S", "e", "x", "T", "y", "A", "U", "g", "0", "z", "B", "h", "1", "C", "V", "2", "D", "W", "j", "3", "E", "X", "4", "F", "Y", "k", "5", "G", "Z", "l", "H", "m", "6", "I", "n", "7") { switch_to 19810520 }
    for_characters("}") { switch_to 19778120 }
    for_characters("f") { switch_to 19810790 }
    for_characters("\n") { switch_to 19811230 }
  }

  at_state(19717460) {
    accept("'")
  }

  at_state(19733520) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
    for_characters("d") { switch_to 19732140 }
  }

  at_state(19745260) {
    accept("where")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19755190) {
    accept("\\/[a-zA-Z]+[a-zA-Z0-9_]*")
    for_characters("K", "V", "6", "k", "v", "a", "A", "L", "W", "7", "l", "w", "b", "B", "M", "X", "8", "m", "x", "C", "N", "Y", "9", "c", "n", "y", "d", "o", "z", "D", "O", "Z", "E", "P", "0", "e", "p", "F", "Q", "1", "f", "q", "G", "R", "2", "g", "r", "H", "S", "3", "h", "s", "I", "T", "4", "i", "t", "_", "J", "U", "5", "j", "u") { switch_to 19755190 }
  }

  at_state(19761360) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("n") { switch_to 19761100 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19716630) {
    accept("\\$[a-zA-Z]+[a-zA-Z0-9_]*")
    for_characters("K", "V", "6", "k", "v", "a", "A", "L", "W", "7", "l", "w", "b", "B", "M", "X", "8", "m", "x", "C", "N", "Y", "9", "c", "n", "y", "D", "O", "Z", "d", "o", "z", "E", "P", "0", "e", "p", "F", "Q", "1", "f", "q", "G", "R", "2", "g", "r", "h", "s", "H", "S", "3", "_", "I", "T", "4", "i", "t", "J", "U", "5", "j", "u") { switch_to 19716630 }
  }

  at_state(19732140) {
    accept("and")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19733780) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("n") { switch_to 19733520 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19774690) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("r") { switch_to 19774430 }
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19782650) {
    for_characters("v", "K", "k", "V", "l", "w", "W", "A", "L", "a", "x", "B", "X", "m", "b", "M", "n", "N", "C", "Y", "c", "y", "d", "D", "o", "O", "Z", "z", "e", "P", "E", "p", "f", "F", "Q", "q", "g", "G", "R", "r", "h", "H", "S", "s", "t", "T", "i", "I", "j", "U", "J", "u") { switch_to 19788410 }
  }

  at_state(19788050) {
    for_characters("K", "V", "k", "v", "6", "A", "w", "L", "7", "W", "a", "l", "B", "M", "8", "x", "X", "b", "m", "9", "y", "Y", "n", "c", "C", "N", "Z", "z", "d", "o", "D", "O", "e", "E", "0", "P", "p", "Q", "q", "1", "F", "f", "r", "G", "R", "g", "2", "3", "S", "h", "s", "H", "t", "I", "T", "4", "i", "_", "U", "u", "5", "j", "J") { switch_to 19788050 }
    for_characters(">") { switch_to 19785790 }
  }

  at_state(19808190) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("K", "V", "6", "k", "v", "a", "A", "L", "W", "7", "l", "w", "b", "B", "M", "X", "8", "m", "x", "C", "N", "Y", "9", "c", "n", "y", "D", "O", "Z", "d", "o", "z", "E", "P", "0", "e", "p", "F", "Q", "1", "f", "q", "g", "r", "G", "R", "2", "H", "S", "3", "h", "s", "I", "T", "4", "i", "t", "_", "J", "U", "5", "j", "u") { switch_to 19808190 }
  }

  at_state(19811230) {
    accept("\n")
    for_characters(" ", "\r", "\t", "\n") { switch_to 19811720 }
  }

  at_state(19724600) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("r") { switch_to 19722620 }
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19746800) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("e") { switch_to 19745260 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19747320) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("e") { switch_to 19747060 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19761100) {
    accept("in")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19709430) {
    accept("\\(")
  }

  at_state(19747060) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("r") { switch_to 19746800 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19774430) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("n") { switch_to 19773290 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19777390) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("u") { switch_to 19774690 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19797000) {
    accept("[<>=][<>=]?")
    for_characters("/") { switch_to 19788650 }
    for_characters("<", "=", ">") { switch_to 19796730 }
    for_characters("K", "V", "k", "v", "a", "A", "L", "W", "l", "w", "b", "B", "M", "X", "m", "x", "c", "n", "y", "C", "N", "Y", "D", "O", "Z", "d", "o", "z", "E", "P", "e", "p", "F", "Q", "f", "q", "G", "R", "g", "r", "H", "S", "h", "s", "I", "T", "i", "t", "J", "U", "j", "u") { switch_to 19796450 }
  }

  at_state(19810520) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19810790) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("o") { switch_to 19803890 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19747990) {
    accept("\\)")
  }

  at_state(19773290) {
    accept("return")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19777910) {
    accept("[a-zA-Z0-9]+[a-zA-Z0-9_]*")
    for_characters("_") { switch_to 19808190 }
    for_characters("e") { switch_to 19777650 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

  at_state(19801910) {
    accept("for")
    for_characters("_") { switch_to 19808190 }
    for_characters("6", "v", "k", "V", "K", "w", "W", "l", "L", "A", "7", "a", "B", "8", "b", "X", "M", "m", "x", "9", "Y", "N", "n", "y", "c", "C", "O", "Z", "o", "d", "D", "z", "E", "p", "0", "P", "e", "1", "q", "Q", "f", "F", "G", "2", "R", "r", "g", "S", "3", "h", "H", "s", "4", "t", "i", "I", "T", "J", "u", "5", "U", "j") { switch_to 19810520 }
  }

end