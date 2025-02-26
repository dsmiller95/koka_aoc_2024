module emit

import lib/assert

pub effect emit<s>
  fun emit(item : s): ()

pub fun collect-exceptions( action ) {
  var ls : list<exception> := []
  handle(action)
    fun emit(item)
      ls := ls ++ [item]
    return(x) (x, ls)
}

pub fun collect-anything( action ) {
  var ls := []
  handle(action)
    fun emit(item)
      ls := ls ++ [item]
    return(x) (x, ls)
}

pub fun map-or-exn-emit( list: list<a>, mapfn: a -> <exn> b ): <emit<exception>> list<b> {
  map-or-emit( list ) fn(item)
     either(try(fn() mapfn(item)))
}

pub fun map-or-emit( list: list<a>, mapfn: a -> <emit<b>|e> either<b, c> ): <emit<b>|e> list<c> {
  list.filter-map fn(item)
    match mapfn(item)
      Left(err) -> { emit(err); Nothing }
      Right(x) -> Just(x)
}

pub fun try-emit( action : () -> <exn|e> () ) : <emit<exception>|e> () {
  with final ctl throw-exn(exn) emit(exn)
  mask<emit<exception>> { action() }
}


fun emits-test()
  with collect-anything
  emit("hello")
  emit("world")
  emit("!")
  ()


pub fun test() {
  emits-test().snd.assert-eq(["hello", "world", "!"])
}