/// Debug functions

import Prim "mo:⛔";
import Runtime "Runtime";

module {

  public func print(text : Text) {
    Prim.debugPrint text
  };

  public func todo() : None {
    Runtime.trap("Debug.todo()")
  };

}
