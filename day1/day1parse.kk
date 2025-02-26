
import std/text/parse

import lib/emit

pub fun parse-number() {
  val digits = parse/digits();
  var number := digits.parse-int();
  match number {
    Nothing -> parse/fail("expected a number, got: " ++ digits)
    Just(n) -> n
  }
}

pub fun parse-two-numbers(): parse (int,int) {
  val firstNum = parse-number();
  parse/many1(parse/white);
  val secondNum = parse-number();
  (firstNum, secondNum)
}

pub fun parse-list( lines: list<string> ) {
  with line <- lines.map-or-exn-emit
  match parse(line.slice, parse-two-numbers) {
    ParseOk(result, _) -> result
    ParseError(msg, rest) -> exn/throw("Couldn't parse '" ++ msg ++ "' from '" ++ line ++ "' with '" ++ rest.show() ++ "' remaining")
  }
}