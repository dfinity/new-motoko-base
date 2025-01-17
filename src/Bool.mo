/// Boolean type and operations.
///
/// While boolean operators `_ and _` and `_ or _` are short-circuiting,
/// avoiding computation of the right argument when possible, the functions
/// `logand(_, _)` and `logor(_, _)` are *strict* and will always evaluate *both*
/// of their arguments.

import Prim "mo:⛔";
import Iter "IterType";

module {

  /// Booleans with constants `true` and `false`.
  public type Bool = Prim.Types.Bool;

  /// Returns `x and y`.
  public func logicalAnd(a : Bool, b : Bool) : Bool { a and b };

  /// Returns `x or y`.
  public func logicalOr(a : Bool, b : Bool) : Bool { a or b };

  /// Returns exclusive or of `x` and `y`, `x != y`.
  public func logicalXor(a : Bool, b : Bool) : Bool { a != b };

  /// Returns `not x`.
  public func logicalNot(bool : Bool) : Bool { not bool };

  /// Returns `x == y`.
  public func equal(a : Bool, b : Bool) : Bool {
    a == b
  };

  /// Returns `x != y`.
  public func compare(a : Bool, b : Bool) : { #less; #equal; #greater } {
    if (a == b) { #equal } else if (a) { #greater } else { #less }
  };

  // Returns either `"true"` or `"false"` corresponding to the input value.
  public func toText(bool : Bool) : Text {
    if bool "true" else "false"
  };

  // Returns an iterator over all possible boolean values (`true` and `false`).
  public func allValues() : Iter.Iter<Bool> = object {
    var state : ?Bool = ?true;
    public func next() : ?Bool {
      switch state {
        case (?true) { state := ?false; ?true };
        case (?false) { state := null; ?false };
        case null { null }
      }
    }
  };

}
