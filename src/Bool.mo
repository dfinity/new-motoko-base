/// Boolean types and operations

import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Bool = Prim.Types.Bool;

  public func logicalAnd(b1 : Bool, b2 : Bool) : Bool { b1 and b2 };

  public func logicalOr(b1 : Bool, b2 : Bool) : Bool { b1 or b2 };

  public func logicalXor(b1 : Bool, b2 : Bool) : Bool { b1 != b2 };

  public func logicalNot(b : Bool) : Bool { not b };

  public func toText(b : Bool) : Text {
    todo()
  };

  public func compare(b1 : Bool, b2 : Bool) : { #less; #equal; #greater } {
    todo()
  };

}
