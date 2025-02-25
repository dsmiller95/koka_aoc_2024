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


effect emit<s>
  fun emit(item : s): ()

pub fun collect-emits( action ) {
  var emits_agg := []
  handle(action)
    fun emit(item) emits_agg := emits_agg ++ [item]
    return(x) (x, emits_agg)
}

pub fun try-emit( action ) {
  with final ctl throw-exn(exn) emit(exn)
  action()
}
pub fun try-emit-variant( action ) {
  try {
    action()
  } fn(e) {
    emit(e)
  }
}

pub fun emits-test()
  with collect-emits
  emit("hello")
  emit("world")
  emit("!")
  ()
pub fun emits-test-two()
  with collect-emits
  try-emit-variant
    throw("error")
    emit(Exception("error unreachable", ExnError))
  try-emit-variant
    throw("error2")
  ()

pub fun map-or-emit( list: list<a>, mapfn: a -> <exn> b ): <emit<exception>> list<b> {
  list.filter-map fn(item)
    match try(fn() mapfn(item))
      Ok(x) -> Just(x)
      Error(err) -> { emit(err); Nothing }
}

pub fun parse-list( lines: list<string> ) {
  with line <- lines.map-or-emit
  match parse(line.slice, parse-two-numbers) {
    ParseOk(result, _) -> result
    ParseError(msg, rest) -> exn/throw("Couldn't parse '" ++ msg ++ "' from '" ++ line ++ "' with '" ++ rest.show() ++ "' remaining")
  }
}

pub fun solve_problem( lines: list<string> ): <console,div> (int, list<exception>) {
  with collect-emits
  var res := parse-list(lines);
  println("Parsed lines:")
  res.foreach fn(item)
    item.println()
  0
}

pub fun run_problem( filename: string ) : <exn,fsys,console,div> int {
  var content := read-text-file(("day/1/" ++ filename).path).lines;
  var res := solve_problem(content)
  
  println("Errors:")
  res.snd.list/foreach fn(item)
    item.println()
  res.fst
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
  println( "emits-test" )
  println( emits-test() )
  println( "emits-test-two" )
  println( emits-test-two() )
  println( "day 1" )
  run_problem("example_11").assert-eq(11)
}