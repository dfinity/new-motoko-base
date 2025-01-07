/// Boolean types and operations

import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Bool = Prim.Types.Bool;

  public func logicalAnd(a : Bool, b : Bool) : Bool { a and b };

  public func logicalOr(a : Bool, b : Bool) : Bool { a or b };

  public func logicalXor(a : Bool, b : Bool) : Bool { a != b };

  public func logicalNot(bool : Bool) : Bool { not bool };

  public func toText(bool : Bool) : Text {
    todo()
  };

  public func compare(a : Bool, b : Bool) : { #less; #equal; #greater } {
    todo()
  };

}
