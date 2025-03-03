module dice-sim

import std/num/random
import std/num/int32

effect dice
  fun roll() : int

effect encounter-die
  fun get() : int
  fun set(new: int) : ()

type encounter
  con Bad
  con NothingHappens
  con Loot


fun roll-encounter(): <dice,encounter-die> (encounter) {
  var encounter-value := get();
  var roll-value := roll();
  if roll-value < encounter-value then {
    set(roll-value);
    return Bad;
  }
  if roll-value == 6 then {
    set(roll());
    return Loot;
  }
  set(encounter-value + 1);
  return NothingHappens;
}

fun encounter-state(initial: int, action){
  var s := initial;
  handle(action)
    fun get() s
    fun set(x) s := x
}

fun d6(action) {
  handle(action)
    fun roll() {
      var smallInt := srandom-int32-range(int32(1), int32(6))
      int(smallInt)
    }
    return(x) x
}

fun simulate-encounter() {
  with d6
  with encounter-state(roll())
  var result := roll-encounter();
  result
}



pub fun main()
  println( "hello world" )
  var result := simulate-encounter();
  var printRes := match result {
    Bad -> "Bad"
    NothingHappens -> "Nothing"
    Loot -> "Loot"
  };
  println(printRes)