import std/core/undiv


pub fun while-no-diverge(
  limit : int,
  predicate,
  action
) {
  if predicate() && limit > 0 then {
    action();
    while-no-diverge(pretend-decreasing(limit - 1), predicate, action);
  } else if limit <= 0 then {
    exn/throw("while-no-diverge: limit reached");
  } else {
    ()
  }
}