/// Boolean types and operations

import Prim "mo:⛔";
import { nyi = todo } "Debug";

module {

  public type Bool = Prim.Types.Bool;

  public func toText(b : Bool) : Text {
    todo()
  };

  public func compare(b1 : Bool, b2 : Bool) : { #less; #equal; #greater } {
    todo()
  };

}
