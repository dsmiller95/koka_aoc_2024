module dice-sim

import lib/emit
import lib/control

import std/num/random
import std/num/int32
import std/num/ddouble

effect dice
  fun roll() : int
  fun max-roll(): int

effect encounter-die
  fun get() : int
  fun set(new: int) : ()

type encounter
  con Bad
  con NothingHappens
  con Loot

fun show(encounter: encounter) {
  match encounter {
    Bad -> "Bad"
    NothingHappens -> "Nothing"
    Loot -> "Loot"
  }
}

fun (==)(encounter: encounter, other: encounter) {
  match encounter {
    Bad -> match other {
      Bad -> True
      _ -> False
    }
    NothingHappens -> match other {
      NothingHappens -> True
      _ -> False
    }
    Loot -> match other {
      Loot -> True
      _ -> False
    }
  }
}

fun roll-encounter(): <dice,encounter-die> (encounter) {
  var encounter-value := get();
  var roll-value := roll();
  if roll-value < encounter-value then {
    set(roll-value);
    return Bad;
  }
  set(min(max-roll(), encounter-value + 1));
  if roll-value == 6 then {
    return Loot;
  }
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
      var smallInt := srandom-int32-range(int32(1), int32(7))
      int(smallInt)
    }
    fun max-roll() 6
}

fun count-encounters(action) {
  var totalBad := 0;
  var totalNothing := 0;
  var totalLoot := 0;
  handle(action)
    fun emit(encounter) {
      match encounter {
        Bad -> totalBad := totalBad + 1;
        NothingHappens -> totalNothing := totalNothing + 1;
        Loot -> totalLoot := totalLoot + 1;
      }
    }
    return(x) (totalBad, totalNothing, totalLoot)
}

fun simulate-encounter() {
  with count-encounters
  var iterations := 1;
  var i := 0;
  while-no-diverge(iterations) {i < iterations} {
    simulate-dungeon();
    i := i + 1;
  }
}

fun simulate-dungeon() {
  with d6
  with encounter-state(roll())
  
  var room_count := 10000000;
  var room := 0;
  while-no-diverge(room_count) {room < room_count} {
    emit(roll-encounter());
    room := room + 1;
  }
}

pub fun main()
  println( "hello world" )
  var result := simulate-encounter();
  var total := ddouble(result.fst + result.snd + result.thd);
  println("Bad: " ++ (ddouble/(/)(ddouble(result.fst), total) * ddouble(6)).show());
  println("Nothing: " ++ (ddouble/(/)(ddouble(result.snd), total) * ddouble(6)).show());
  println("Loot: " ++ (ddouble/(/)(ddouble(result.thd), total) * ddouble(6)).show());