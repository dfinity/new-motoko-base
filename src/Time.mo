/// System time

import Prim "mo:⛔";
import Nat "Nat";
import Nat64 "Nat64";

module {

  public type Time = Int;
  public type Duration = {
    #days : Nat;
    #hours : Nat;
    #minutes : Nat;
    #seconds : Nat;
    #milliseconds : Nat;
    #nanoseconds : Nat;
  };

  public let now : () -> Time = func() : Int = Prim.nat64ToNat(Prim.time());

  public type TimerId = Nat;

  public func toNanoseconds(duration : Duration) : Nat {
    switch duration {
      case (#days n) n * 86_400_000_000_000;
      case (#hours n) n * 3_600_000_000_000;
      case (#minutes n) n * 60_000_000_000;
      case (#seconds n) n * 1_000_000_000;
      case (#milliseconds n) n * 1_000_000;
      case (#nanoseconds n) n
    };
  };

  public func setTimer<system>(duration : Duration, job : () -> async ()) : TimerId {
    Prim.setTimer<system>(Nat64.fromNat(toNanoseconds duration), false, job)
  };

  public func recurringTimer<system>(duration : Duration, job : () -> async ()) : TimerId {
    Prim.setTimer<system>(Nat64.fromNat(toNanoseconds duration), true, job)
  };

  public let cancelTimer : TimerId -> () = Prim.cancelTimer;

}
