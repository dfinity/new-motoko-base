/// Signed integer numbers with infinite precision (also called big integers)

import Prim "mo:⛔";
import Hash "Hash";
import Iter "IterType";
import { nyi = todo } "Debug";

module {

  public type Int = Prim.Types.Int;

  public func abs(x : Int) : Nat {
    Prim.abs(x)
  };

  public func toText(x : Int) : Text {
    todo()
  };

  public func min(x : Int, y : Int) : Int {
    if (x < y) { x } else { y }
  };

  public func max(x : Int, y : Int) : Int {
    if (x < y) { y } else { x }
  };

  public func hash(i : Int) : Hash.Hash {
    todo() // New hash function?
  };

  public func equal(x : Int, y : Int) : Bool { x == y };

  public func notEqual(x : Int, y : Int) : Bool { x != y };

  public func less(x : Int, y : Int) : Bool { x < y };

  public func lessOrEqual(x : Int, y : Int) : Bool { x <= y };

  public func greater(x : Int, y : Int) : Bool { x > y };

  public func greaterOrEqual(x : Int, y : Int) : Bool { x >= y };

  public func compare(x : Int, y : Int) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func neg(x : Int) : Int { -x };

  public func add(x : Int, y : Int) : Int { x + y };

  public func sub(x : Int, y : Int) : Int { x - y };

  public func mul(x : Int, y : Int) : Int { x * y };

  public func div(x : Int, y : Int) : Int { x / y };

  public func rem(x : Int, y : Int) : Int { x % y };

  public func pow(x : Int, y : Int) : Int { x ** y };

  public class range(fromInclusive : Int, toExclusive : Int) {
    todo()
  };

}
