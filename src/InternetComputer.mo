/// Originally `ExperimentalInternetComputer.mo`

import Prim "mo:⛔";

module {

  public let call : (canister : Principal, name : Text, data : Blob) -> async (reply : Blob) = Prim.call_raw;

  public func countInstructions(comp : () -> ()) : Nat64 {
    let init = Prim.performanceCounter(0);
    let pre = Prim.performanceCounter(0);
    comp();
    let post = Prim.performanceCounter(0);
    // performance_counter costs around 200 extra instructions; we perform an empty measurement to decide the overhead
    let overhead = pre - init;
    post - pre - overhead
  };

  public let performanceCounter : (counter : Nat32) -> (value: Nat64) = Prim.performanceCounter;

  public func replyDeadline() : Nat = Prim.nat64ToNat(Prim.replyDeadline());

}
