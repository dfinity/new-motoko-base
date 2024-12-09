/// Debug functions

import Prim "mo:⛔";

module {

  public func print(text : Text) {
    Prim.debugPrint text
  };

  public func trap(errorMessage : Text) : None {
    Prim.trap errorMessage
  };

  public func nyi() : None {
    trap("Debug.nyi()")
  };

  public func unreachable() : None {
    trap("Debug.unreachable()")
  };

}
