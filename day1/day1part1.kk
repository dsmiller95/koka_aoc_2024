module day1part1

import std/core/undiv
import std/os/path
import std/os/file

import lib/emit
import lib/assert
import lib/sort
import lib/state

import day1/day1parse

pub fun solve_problem( lines: list<string> ): <console> (int, list<exception>) {
  with collect-exceptions
  var parsed_lines := parse-list(lines);
  println("Parsed " ++ parsed_lines.list/length().show() ++" lines:")

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
  var content := read-text-file(("day1/" ++ filename).path).lines;
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