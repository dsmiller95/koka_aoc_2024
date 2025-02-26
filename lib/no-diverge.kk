import std/core/undiv

import lib/assert


pub fun while-no-diverge(
  limit : int,
  predicate,
  action
) {
  if predicate() && limit >= 0 then {
    action();
    while-no-diverge(pretend-decreasing(limit - 1), predicate, action);
  } else if limit < 0 then {
    exn/throw("while-no-diverge: limit reached");
  } else {
    ()
  }
}

fun loop-up-diverge(to : int) {
  var i := 0;
  var res := 0;
  while { i < to }
    i := i + 1;
    res := res + i
  res
}

fun loop-up-no-diverge(to : int, limit : int) {
  var i := 0;
  var res := 0;
  while-no-diverge(limit) { i < to }
    i := i + 1
    res := res + i
  res
}

pub fun test() {
  loop-up-diverge(5).assert-eq(15, "diverging loop");
  loop-up-no-diverge(5, 5).assert-eq(15, "non-diverging loop");
  try { loop-up-no-diverge(5, 4) }.is-error().assert-eq(True, "non-diverging loop hits limit");
}