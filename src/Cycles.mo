/// Original: `ExperimentalCycles.mo`

import Prim "mo:⛔";

module {

  public let balance : () -> (amount : Nat) = Prim.cyclesBalance;

  public let available : () -> (amount : Nat) = Prim.cyclesAvailable;

  public let accept : <system>(amount : Nat) -> (accepted : Nat) = Prim.cyclesAccept;

  public let add : <system>(amount : Nat) -> () = Prim.cyclesAdd;

  public let refunded : () -> (amount : Nat) = Prim.cyclesRefunded;

}
