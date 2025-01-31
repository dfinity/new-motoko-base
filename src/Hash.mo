/// Hash values

import Prim "mo:⛔";
import Iter "Iter";

module {

  /// Hash values represent a string of _hash bits_, packed into a `Nat32`.
  public type Hash = Nat32;

  /// The hash length, always 31.
  public let length : Nat = 31; // Why not 32?

  /// Project a given bit from the bit vector.
  public func bit(h : Hash, pos : Nat) : Bool {
    assert (pos <= length);
    (h & (Prim.natToNat32(1) << Prim.natToNat32(pos))) != Prim.natToNat32(0)
  };

  /// Test if two hashes are equal
  public func equal(ha : Hash, hb : Hash) : Bool {
    ha == hb
  };

}
