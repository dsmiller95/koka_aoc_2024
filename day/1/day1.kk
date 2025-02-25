module day1

import std/core/undiv
import std/os/path
import std/os/file
import std/text/parse

pub fun parse-number() {
  val digits = parse/digits();
  var number := digits.parse-int();
  match number {
    Nothing -> fail("expected a number, got: " ++ digits)
    Just(n) -> n
  }
}

pub fun parse-two-numbers(): parse (int,int) {
  val firstNum = parse-number();
  many1(white);
  val secondNum = parse-number();
  (firstNum, secondNum)
}


effect state<s>
  ctl get()      : s
  ctl set(x : s) : ()

fun returnState(initial: int, action)
  var s := initial
  handle(action)
    fun get()  s
    fun set(x) s := x
    return(x) s


pub fun collect-anything( action ) {
  var ls := []
  handle(action)
    fun emit(item)
      ls := ls ++ [item]
    return(x) (x, ls)
}

pub fun try-emit( action : () -> <exn|e> () ) : <emit<exception>|e> () {
  with final ctl throw-exn(exn) emit(exn)
  mask<emit<exception>> { action() }
}
pub fun try-emit-variant( action ) {
  try {
    action()
  } fn(e) {
    emit(e)
  }
}

effect emit<s>
  fun emit(item : s): ()

pub fun collect-exceptions( action ) {
  var ls : list<exception> := []
  handle(action)
    fun emit(item)
      ls := ls ++ [item]
    return(x) (x, ls)
}

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

pub fun solve_problem( lines: list<string> ): <console> (int, list<exception>) {
  with collect-exceptions
  var parsed_lines := parse-list(lines);
  println("Parsed lines:")
  parsed_lines.foreach fn(item)
    item.println()

  var unzipped := parsed_lines.unzip();
  var x := unzipped.fst;
  var y := unzipped.snd;

  with returnState(0)

  try-emit
    var sorted_x := mask<local> { quick_sort(x, x.length()) }
    var sorted_y := mask<local> { quick_sort(y, y.length()) }
    var rezipped := list/zipwith(sorted_x, sorted_y, fn(a,b) abs(a - b))
      .sum()
    set(rezipped)
    ()
}

pub fun quick_sort( list: list<int>, len: int ) : <exn|e> list<int> {
  var min := list.minimum(0)
  var max := list.maximum(0)
  if min == max then return list;
  var pivot := (min + max) / 2;
  if pivot == min then pivot := max

  var split := list.partition fn(item) item < pivot;

  var lenL := split.fst.length();
  var lenR := split.snd.length();
  assert(lenL < len, "left len must decrease")
  assert(lenR < len, "right len must decrease")

  quick_sort(split.fst, pretend-decreasing(lenL)) 
    ++
  quick_sort(split.snd, pretend-decreasing(lenR))
}


pub fun run_problem( filename: string ) : <exn,fsys,console> int {
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

pub fun emits-test()
  with collect-anything
  emit("hello")
  emit("world")
  emit("!")
  ()
pub fun emits-test-two()
  with collect-anything
  try-emit-variant
    throw("error")
    emit(Exception("error unreachable", ExnError))
  try-emit-variant
    throw("error2")
  ()


pub fun test_sort() {
  println("quick_sort started")
  var list := [3, 4, 1, 2, 5];
  var sorted := quick_sort(list, list.length());
  assert(sorted == [1, 2, 3, 4, 5], "quick_sort failed")
  list := [-2, 3, 54, 0, 0, 2, 2, 0, 1];
  sorted := quick_sort(list, list.length());
  assert(sorted == [-2, 0, 0, 0, 1, 2, 2, 3, 54], "quick_sort failed")
  println("quick_sort passed")
}

pub fun main(): <pure,console,fsys> () {
  println( "test sort" )
  println( test_sort() )

  println( "emits-test" )
  println( emits-test() )
  println( "emits-test-two" )
  println( emits-test-two() )

  println( "day 1" )
  run_problem("example_11").assert-eq(11)

  println("real result: " ++ run_problem("input").show())
}