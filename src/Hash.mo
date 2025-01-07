/// `Hash` utilities

import Prim "mo:⛔";
import Iter "Iter";
import { todo } "Debug";

module {

  public type Hash = Nat32;

  public let length : Nat = 31;

  public func bit(hash : Hash, pos : Nat) : Bool {
    todo()
  };

  public func equal(hash1 : Hash, hash2 : Hash) : Bool {
    hash1 == hash2
  };

  public func hash(nat : Nat) : Hash {
    todo()
  };

  public func debugPrintBits(bits : Hash) {
    todo()
  };

  public func debugPrintBitsRev(bits : Hash) {
    todo()
  };

}
