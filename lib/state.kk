module state

import lib/assert


pub effect state<s>
  ctl get()      : s
  ctl set(x : s) : ()

pub fun returnState(initial: int, action)
  var s := initial
  handle(action)
    fun get()  initial
    fun set(x) s := x
    return(x) s

pub fun int-state(initial: int, action)
  var s := initial
  handle(action)
    fun get()  s
    fun set(x) s := x
    return(x) (x, s)

fun test_state_1() {
  with int-state(3)
  var x := get();
  set(x + 1);
  var y := get();
  y.assert-eq(4)
  42
}

fun test_state_2() {
  with returnState(3)
  set(31);
  var y := get();
  y.assert-eq(3)
  42
}

pub fun test() {
  test_state_1().assert-eq((42,4))
  test_state_2().assert-eq(31)
}