// Runtime utilities

import Prim "mo:⛔";

module {

  public func trap(errorMessage : Text) : None {
    Prim.trap errorMessage
  };

  public func unreachable() : None {
    trap("Runtime.unreachable()")
  };

}
