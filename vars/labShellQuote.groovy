// labShellQuote('it\'s')  ->  'it'"'"'s'
//
// Wraps a value in single quotes for /bin/sh so it is passed as one literal
// argument: no variable expansion, globbing or word splitting.
String call(String value) {
  return "'" + (value ?: '').replace("'", "'\"'\"'") + "'"
}
