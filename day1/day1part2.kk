module day1part2

import std/core/undiv
import std/os/path
import std/os/file

import lib/emit
import lib/assert
import lib/sort
import lib/state
import lib/no-diverge

import day1/day1parse


effect twin-deque
  fun dequeue-left() : maybe<int>
  fun peek-left() : maybe<int>
  fun dequeue-right() : maybe<int>
  fun peek-right() : maybe<int>

fun twin-dequeue-from(left: list<int>, right: list<int>, action) {
  var left-var := left;
  var right-var := right;
  handle(action)
    fun dequeue-left()
      match left-var {
        Nil -> Nothing
        Cons(x, xx) -> { left-var := xx; Just(x) }
      }
    fun peek-left()
      match left-var {
        Nil -> Nothing
        Cons(x, _) -> { Just(x) }
      }
    fun dequeue-right()
      match right-var {
        Nil -> Nothing
        Cons(x, xx) -> { right-var := xx; Just(x) }
      }
    fun peek-right()
      match right-var {
        Nil -> Nothing
        Cons(x, _) -> { Just(x) }
      }
  ()
}

fun min-maybe(a: maybe<int>, b: maybe<int>) : maybe<int> {
  match (a, b) {
    (Nothing, _) -> Nothing
    (_, Nothing) -> Nothing
    (Just(x), Just(y)) -> Just(min(x, y))
  }
}

pub fun take-runs-then-mult(max-len: int) : <twin-deque,exn,console> int {
  var current-item := min-maybe(peek-left(), peek-right());
  var left-run := 1;
  var right-run := 0;
  var result := 0;

  while-no-diverge(max-len) { current-item != Nothing } {
    while-no-diverge(max-len) { peek-left() == current-item }
      left-run := left-run + 1;
      dequeue-left();
      ()
    while-no-diverge(max-len) { peek-right() == current-item }
      right-run := right-run + 1;
      dequeue-right();
      ()
    result := result + left-run * right-run * (match current-item {
      Nothing -> exn/throw("unreachable")
      Just(x) -> x
    });

    println(current-item.show() ++ " " ++ left-run.show() ++ " " ++ right-run.show() ++
       " " ++ peek-left().show() ++ " " ++ peek-right().show() ++ " " ++ result.show())

    left-run := 0;
    right-run := 0;

    current-item := min-maybe(peek-left(), peek-right())
  }

  result
}

pub fun solve_problem( lines: list<string> ): <console> (int, list<exception>) {
  with collect-exceptions
  var parsed_lines := parse-list(lines);

  var unzipped := parsed_lines.unzip();
  var x := unzipped.fst;
  var y := unzipped.snd;

  with returnState(0)

  try-emit
    var sorted_x := mask<local> { quick_sort(x, x.length()) }
    var sorted_y := mask<local> { quick_sort(y, y.length()) }
    var max_iters := sorted_x.length() + sorted_y.length();

    with twin-dequeue-from(sorted_x, sorted_y)
    var result := take-runs-then-mult(max_iters);
    set(result)
    println("result out " ++ result.show());
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
  println( "day 1 part 2" )
  run_problem("example").assert-eq(31)

  println("real result: " ++ run_problem("input").show())
}