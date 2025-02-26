module sort

import std/core/undiv

import lib/assert

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


fun test_sort_1() {
  var list := [3, 4, 1, 2, 5];
  var sorted := quick_sort(list, list.length());
  assert(sorted == [1, 2, 3, 4, 5], "quick_sort failed")
}

fun test_sort_2() {
  var list := [-2, 3, 54, 0, 0, 2, 2, 0, 1];
  var sorted := quick_sort(list, list.length());
  assert(sorted == [-2, 0, 0, 0, 1, 2, 2, 3, 54], "quick_sort failed")
}


pub fun test(){
  test_sort_1()
  test_sort_2()
}