module day1part1

import std/core/undiv
import std/os/path
import std/os/file
import std/text/parse

import lib/emit
import lib/assert
import lib/sort
import lib/state

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

pub fun parse-list( lines: list<string> ) {
  with line <- lines.map-or-exn-emit
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

pub fun run_problem( filename: string ) : <exn,fsys,console> int {
  var content := read-text-file(("day/1/" ++ filename).path).lines;
  var res := solve_problem(content)
  
  println("Errors:")
  res.snd.list/foreach fn(item)
    item.println()
  res.fst
}

pub fun main(): <pure,console,fsys> () {
  println( "day 1" )
  run_problem("example_11").assert-eq(11)

  println("real result: " ++ run_problem("input").show())
}