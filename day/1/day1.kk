module day1

import std/os/path
import std/os/file
import std/text/parse

value struct tuple<a,b>
  a: a
  b: b

// fun tuple/show(tuple: tuple<a,b>, ?showA: a -> string, ?showB: b -> string): string {
//   "(" ++ showA(tuple.a) ++ ", " ++ showB(tuple.b) ++ ")"
// }
fun tuple/show(t: tuple<int,int>): string {
  "(" ++ t.a.show() ++ ", " ++ t.b.show() ++ ")"
}

pub fun parse-number() {
  val digits = parse/digits();
  var number := digits.parse-int();
  match number {
    Nothing -> fail("expected a number, got: " ++ digits)
    Just(n) -> n
  }
}

pub fun parse-two-numbers(): parse tuple<int,int> {
  val firstNum = parse-number();
  many1(white);
  val secondNum = parse-number();
  Tuple(firstNum, secondNum)
}

pub fun solve_problem( lines: list<string> ): console int {
  var split-lines := lines.map fn(line)
    parse(line.slice, parse-two-numbers)
  
  split-lines.foreach fn(item)
    match item  {
      ParseOk(result, _) -> result.show/println()
      ParseError(msg, _) -> msg.println()
    }
  0
}

pub fun run_problem( filename: string ) : <exn,fsys,console> int {
  var content := read-text-file(("day/1/" ++ filename).path).lines;
  solve_problem(content)
}

pub fun assert( is-true: bool, message: string ) {
  if !is-true then {
    throw(message)
  }
}

pub fun assert-eq<a>( actual: a, expected: a, ?(==) : (a,a) -> bool, ?show: a -> string ) {
  if !(actual == expected) then {
    throw("(expected: " ++ show(expected) ++ ", actual: " ++ show(actual) ++ ")")
  }
}

pub fun main(){
  println( "day 1" )
  run_problem("example_11").assert-eq(11)
}