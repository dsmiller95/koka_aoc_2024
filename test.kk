import lib/emit
import lib/assert
import lib/sort
import lib/state
import lib/control

pub fun main() {
  println("test assert")
  assert/test();

  println("test emit")
  emit/test();
  
  println("test sort")
  sort/test();

  println("test state")
  state/test();

  println("test control")
  control/test();

  println("tests pass!")
}