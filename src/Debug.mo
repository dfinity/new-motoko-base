/// Debug functions

import Prim "mo:⛔";

module {

  public func print(text : Text) {
    Prim.debugPrint text
  };

  public func trap(errorMessage : Text) : None {
    Prim.trap errorMessage
  };

  public func todo() : None {
    trap("Debug.todo()")
  };

  public func unreachable() : None {
    trap("Debug.unreachable()")
  };

}
