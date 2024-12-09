/// Hash values

import Prim "mo:⛔";
import Iter "Iter";
import { nyi = todo } "Debug";

module {

  public type Hash = Nat32;

  public let length : Nat = 31; // Why not 32?

  public func bit(h : Hash, pos : Nat) : Bool {
    todo()
  };

  public func equal(ha : Hash, hb : Hash) : Bool {
    ha == hb
  };

  public func hash(n : Nat) : Hash {
    todo()
  };

  public func debugPrintBits(bits : Hash) {
    todo()
  };

  public func debugPrintBitsRev(bits : Hash) {
    todo()
  };
}
