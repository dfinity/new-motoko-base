/// Natural numbers with infinite precision

import Int "Int";
import Iter "Iter";
import { todo } "Debug";
import Prim "mo:⛔";

module {

  public type Nat = Prim.Types.Nat;

  public func toText(n : Nat) : Text = Int.toText n;

  public func fromText(text : Text) : ?Nat {
    todo()
  };

  public func fromInt(i : Int) : ?Nat {
    todo()
  };

  public func min(x : Nat, y : Nat) : Nat {
    if (x < y) { x } else { y }
  };

  public func max(x : Nat, y : Nat) : Nat {
    if (x < y) { y } else { x }
  };

  public func equal(x : Nat, y : Nat) : Bool { x == y };

  public func notEqual(x : Nat, y : Nat) : Bool { x != y };

  public func less(x : Nat, y : Nat) : Bool { x < y };

  public func lessOrEqual(x : Nat, y : Nat) : Bool { x <= y };

  public func greater(x : Nat, y : Nat) : Bool { x > y };

  public func greaterOrEqual(x : Nat, y : Nat) : Bool { x >= y };

  public func compare(x : Nat, y : Nat) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func add(x : Nat, y : Nat) : Nat { x + y };

  public func sub(x : Nat, y : Nat) : Nat { x - y };

  public func mul(x : Nat, y : Nat) : Nat { x * y };

  public func div(x : Nat, y : Nat) : Nat { x / y };

  public func rem(x : Nat, y : Nat) : Nat { x % y };

  public func pow(x : Nat, y : Nat) : Nat { x ** y };

  public func bitshiftLeft(x : Nat, y : Nat32) : Nat { Prim.shiftLeft(x, y) };

  public func bitshiftRight(x : Nat, y : Nat32) : Nat { Prim.shiftRight(x, y) };

  public func allValues() : Iter.Iter<Nat> {
    todo()
  };

}
