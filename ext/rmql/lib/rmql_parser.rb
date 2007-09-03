class RMQLParser < Dhaka::CompiledParser

  self.grammar = RMQLGrammar

  start_with 0

  at_state(44) {
    for_symbols("and", "or", "return", ")", "COMPARISON") { reduce_with "word_scalar" }
  }

  at_state(33) {
    for_symbols("return") { reduce_with "condition_def" }
    for_symbols("and") { shift_to 36 }
    for_symbols("or") { shift_to 34 }
  }

  at_state(30) {
    for_symbols("END_TAG") { reduce_with "word_w_next" }
  }

  at_state(1) {
    for_symbols("_End_") { reduce_with "query" }
  }

  at_state(39) {
    for_symbols("QUOTE") { shift_to 40 }
  }

  at_state(34) {
    for_symbols("scalar_exp") { shift_to 41 }
    for_symbols("and", "or", "return", ")") { reduce_with "search_empty" }
    for_symbols("atom") { shift_to 44 }
    for_symbols("(") { shift_to 48 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("v_selection") { shift_to 45 }
    for_symbols("QUOTE") { shift_to 38 }
    for_symbols("predicate") { shift_to 46 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("comparison_predicate") { shift_to 47 }
    for_symbols("search_condition") { shift_to 35 }
  }

  at_state(11) {
    for_symbols("where", "and", "or", "}", "return", ")", "COMPARISON") { reduce_with "field_w_next" }
  }

  at_state(5) {
    for_symbols("VARIABLE") { shift_to 6 }
  }

  at_state(2) {
    for_symbols("for") { shift_to 5 }
    for_symbols("Main") { shift_to 3 }
  }

  at_state(53) {
    for_symbols("where", "return") { reduce_with "model_variable" }
  }

  at_state(51) {
    for_symbols("fields") { shift_to 52 }
    for_symbols("FIELD_SELECTION") { shift_to 10 }
    for_symbols("where", "return") { reduce_with "field_noop" }
  }

  at_state(46) {
    for_symbols("and", "or", "return", ")") { reduce_with "search_w_predicate" }
  }

  at_state(43) {
    for_symbols("and", "or", "return", ")") { reduce_with "comparison" }
  }

  at_state(31) {
    for_symbols("END_TAG", "}", "_End_") { reduce_with "selection" }
  }

  at_state(23) {
    for_symbols("END_TAG") { reduce_with "variable_selection" }
  }

  at_state(19) {
    for_symbols("Main") { shift_to 20 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("for") { shift_to 5 }
    for_symbols("v_selection") { shift_to 22 }
  }

  at_state(16) {
    for_symbols("atom") { shift_to 29 }
    for_symbols("word_list") { shift_to 28 }
    for_symbols("START_TAG") { shift_to 24 }
    for_symbols("{") { shift_to 19 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("content") { shift_to 17 }
  }

  at_state(49) {
    for_symbols("and") { shift_to 36 }
    for_symbols(")") { shift_to 50 }
    for_symbols("or") { shift_to 34 }
  }

  at_state(40) {
    for_symbols("and", "or", "return", ")", "COMPARISON") { reduce_with "quoted_word" }
  }

  at_state(37) {
    for_symbols("and", "or", "return", ")") { reduce_with "search_w_and" }
  }

  at_state(28) {
    for_symbols("END_TAG") { reduce_with "content_words" }
  }

  at_state(27) {
    for_symbols("END_TAG") { reduce_with "sibling" }
  }

  at_state(52) {
    for_symbols("where", "return") { reduce_with "model_standard" }
  }

  at_state(42) {
    for_symbols("atom") { shift_to 44 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("v_selection") { shift_to 45 }
    for_symbols("scalar_exp") { shift_to 43 }
    for_symbols("QUOTE") { shift_to 38 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
  }

  at_state(22) {
    for_symbols("}") { shift_to 23 }
  }

  at_state(17) {
    for_symbols("END_TAG") { shift_to 18 }
  }

  at_state(14) {
    for_symbols("return") { shift_to 15 }
    for_symbols("result_exp") { shift_to 31 }
  }

  at_state(8) {
    for_symbols("where", "FIELD_SELECTION", "and", "or", "WORD_LITERAL", "END_TAG", "QUOTE", "return", ")", "COMPARISON") { reduce_with "atom" }
  }

  at_state(48) {
    for_symbols("scalar_exp") { shift_to 41 }
    for_symbols("search_condition") { shift_to 49 }
    for_symbols("and", "or", ")") { reduce_with "search_empty" }
    for_symbols("atom") { shift_to 44 }
    for_symbols("(") { shift_to 48 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("v_selection") { shift_to 45 }
    for_symbols("QUOTE") { shift_to 38 }
    for_symbols("predicate") { shift_to 46 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("comparison_predicate") { shift_to 47 }
  }

  at_state(45) {
    for_symbols("and", "or", "return", ")", "COMPARISON") { reduce_with "variable_sel_scalar" }
  }

  at_state(21) {
    for_symbols("END_TAG") { reduce_with "sub_selection" }
  }

  at_state(9) {
    for_symbols("fields") { shift_to 12 }
    for_symbols("FIELD_SELECTION") { shift_to 10 }
    for_symbols("where", "and", "or", "}", "return", ")", "COMPARISON") { reduce_with "variable" }
  }

  at_state(4) {
    for_symbols("_End_") { reduce_with "query_w_tags" }
  }

  at_state(41) {
    for_symbols("COMPARISON") { shift_to 42 }
  }

  at_state(26) {
    for_symbols("atom") { shift_to 29 }
    for_symbols("END_TAG") { reduce_with "element" }
    for_symbols("word_list") { shift_to 28 }
    for_symbols("START_TAG") { shift_to 24 }
    for_symbols("content") { shift_to 27 }
    for_symbols("{") { shift_to 19 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
  }

  at_state(25) {
    for_symbols("END_TAG") { shift_to 26 }
  }

  at_state(24) {
    for_symbols("atom") { shift_to 29 }
    for_symbols("word_list") { shift_to 28 }
    for_symbols("START_TAG") { shift_to 24 }
    for_symbols("{") { shift_to 19 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("content") { shift_to 25 }
  }

  at_state(13) {
    for_symbols("opt_condition_definition") { shift_to 14 }
    for_symbols("return") { reduce_with "result_exp_prod" }
    for_symbols("where") { shift_to 32 }
  }

  at_state(0) {
    for_symbols("for") { shift_to 5 }
    for_symbols("Main") { shift_to 1 }
    for_symbols("START_TAG") { shift_to 2 }
  }

  at_state(38) {
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("atom") { shift_to 39 }
  }

  at_state(35) {
    for_symbols("and") { shift_to 36 }
    for_symbols("or", "return", ")") { reduce_with "search_w_or" }
  }

  at_state(20) {
    for_symbols("}") { shift_to 21 }
  }

  at_state(12) {
    for_symbols("where", "and", "or", "}", "return", ")", "COMPARISON") { reduce_with "variable_w_fields" }
  }

  at_state(3) {
    for_symbols("END_TAG") { shift_to 4 }
  }

  at_state(47) {
    for_symbols("and", "or", "return", ")") { reduce_with "comparison_predicate_prod" }
  }

  at_state(15) {
    for_symbols("START_TAG") { shift_to 16 }
  }

  at_state(7) {
    for_symbols("v_selection") { shift_to 53 }
    for_symbols("atom") { shift_to 51 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("model_definition") { shift_to 13 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
  }

  at_state(50) {
    for_symbols("and", "or", "return", ")") { reduce_with "search_w_parentheses" }
  }

  at_state(36) {
    for_symbols("scalar_exp") { shift_to 41 }
    for_symbols("and", "or", "return", ")") { reduce_with "search_empty" }
    for_symbols("atom") { shift_to 44 }
    for_symbols("(") { shift_to 48 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("v_selection") { shift_to 45 }
    for_symbols("search_condition") { shift_to 37 }
    for_symbols("QUOTE") { shift_to 38 }
    for_symbols("predicate") { shift_to 46 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("comparison_predicate") { shift_to 47 }
  }

  at_state(32) {
    for_symbols("scalar_exp") { shift_to 41 }
    for_symbols("and", "or", "return") { reduce_with "search_empty" }
    for_symbols("atom") { shift_to 44 }
    for_symbols("(") { shift_to 48 }
    for_symbols("VARIABLE") { shift_to 9 }
    for_symbols("v_selection") { shift_to 45 }
    for_symbols("QUOTE") { shift_to 38 }
    for_symbols("search_condition") { shift_to 33 }
    for_symbols("predicate") { shift_to 46 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("comparison_predicate") { shift_to 47 }
  }

  at_state(29) {
    for_symbols("atom") { shift_to 29 }
    for_symbols("WORD_LITERAL") { shift_to 8 }
    for_symbols("word_list") { shift_to 30 }
    for_symbols("END_TAG") { reduce_with "word" }
  }

  at_state(18) {
    for_symbols("END_TAG", "}", "_End_") { reduce_with "result" }
  }

  at_state(10) {
    for_symbols("fields") { shift_to 11 }
    for_symbols("FIELD_SELECTION") { shift_to 10 }
    for_symbols("where", "and", "or", "}", "return", ")", "COMPARISON") { reduce_with "field_noop" }
  }

  at_state(6) {
    for_symbols("in") { shift_to 7 }
  }

end