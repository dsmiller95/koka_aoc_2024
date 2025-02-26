module maybe-ext

pub fun unwrap(mab: maybe<a>) : exn a {
  match mab {
    Nothing -> throw("unwrap: Nothing")
    Just(x) -> x
  }
}

pub fun min(a: maybe<a>, b: maybe<a>, ?min: (a, a) -> a) : maybe<a> {
  match (a, b) {
    (Nothing, _) -> Nothing
    (_, Nothing) -> Nothing
    (Just(x), Just(y)) -> Just(min(x, y))
  }
}