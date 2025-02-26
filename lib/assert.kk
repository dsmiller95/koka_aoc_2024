module assert

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


pub fun test() {
  5.assert-eq(5)
  "five".assert-eq("five")
  True.assert-eq(True)

  assert(True, "true is success")
}