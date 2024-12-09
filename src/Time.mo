/// System time

import Prim "mo:⛔";
import Nat "Nat";

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

  public func toNanoseconds(duration : Duration) : Nat =
    Nat.fromInt (switch duration {
      case (#days s) s * 86_400_000_000_000;
      case (#hours s) s * 3_600_000_000_000;
      case (#minutes s) s * 60_000_000_000;
      case (#seconds s) s * 1_000_000_000;
      case (#milliseconds s) s * 1_000_000;
      case (#nanoseconds ns) ns });

  public func setTimer<system>(duration : Duration, job : () -> async ()) : TimerId {
    Prim.setTimer<system>(toNanoseconds duration, false, job)
  };

  public func recurringTimer<system>(duration : Duration, job : () -> async ()) : TimerId {
    Prim.setTimer<system>(toNanoseconds duration, true, job)
  };

  public let cancelTimer : TimerId -> () = Prim.cancelTimer;
}
