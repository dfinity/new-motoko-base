/// Random number generation.

import Nat8 "Nat8";
import Text "Text";
import Float "Float";
import Int "Int";
import Nat "Nat";
import Char "Char";
import Nat32 "Nat32";
import Debug "mo:base/Debug";
import Blob "Blob";
import Iter "Iter";
import Runtime "Runtime";
import { todo } "Debug";

module {

  let rawRand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = rawRand;

  /// Opinionated choice of PRNG from a given seed.
  public func new(seed : Blob) : Random {
    Random(
      func() {
        todo()
      }
    )
  };

  /// Uses entropy from the management canister with automatic resupply.
  public func newAsync() : AsyncRandom {
    AsyncRandom(func() : async* Blob { await rawRand() })
  };

  public class Random(generator : () -> Blob) {
    var iter : Iter.Iter<Nat8> = Iter.empty();
    let bitIter : Iter.Iter<Bool> = object {
      var mask = 0x00 : Nat8;
      var byte = 0x00 : Nat8;
      public func next() : ?Bool {
        if (0 : Nat8 == mask) {
          switch (iter.next()) {
            case null { null };
            case (?w) {
              byte := w;
              mask := 0x40;
              ?(0 : Nat8 != byte & (0x80 : Nat8))
            }
          }
        } else {
          let m = mask;
          mask >>= (1 : Nat8);
          ?(0 : Nat8 != byte & m)
        }
      }
    };

    /// Random choice between `true` and `false`.
    public func bool() : Bool {
      switch (bitIter.next()) {
        case (?bit) { bit };
        case null {
          iter := generator().vals();
          switch (bitIter.next()) {
            case (?bit) { bit };
            case null {
              Runtime.trap("Random.bool(): generator produced empty Blob")
            }
          }
        }
      }
    };

    /// Random `Nat8` value in the range [0, 256).
    public func byte() : Nat8 {
      switch (iter.next()) {
        case (?byte) { byte };
        case null {
          iter := generator().vals();
          switch (iter.next()) {
            case (?byte) { byte };
            case null {
              Runtime.trap("Random.byte(): generator produced empty Blob")
            }
          }
        }
      }
    };

    /// Random `Float` value in the range [0, 1).
    public func float() : Float {
      todo()
    };

    public func intRange(from : Int, toExclusive : Int) : Int {
      if (from > toExclusive) {
        Debug.trap("Random.intRange(): from > toExclusive")
      };
      todo()
    };

    public func natRange(from : Nat, toExclusive : Nat) : Nat {
      if (from > toExclusive) {
        Debug.trap("Random.natRange(): from > toExclusive")
      };
      todo()
    };

  };

  public class AsyncRandom(generator : () -> async* Blob) {
    var iter = Iter.empty<Nat8>();
    let bitIter : Iter.Iter<Bool> = object {
      var mask = 0x00 : Nat8;
      var byte = 0x00 : Nat8;
      public func next() : ?Bool {
        if (0 : Nat8 == mask) {
          switch (iter.next()) {
            case null { null };
            case (?w) {
              byte := w;
              mask := 0x40;
              ?(0 : Nat8 != byte & (0x80 : Nat8))
            }
          }
        } else {
          let m = mask;
          mask >>= (1 : Nat8);
          ?(0 : Nat8 != byte & m)
        }
      }
    };

    /// Random choice between `true` and `false`.
    public func bool() : async* Bool {
      switch (bitIter.next()) {
        case (?bit) { bit };
        case null {
          iter := (await* generator()).vals();
          switch (bitIter.next()) {
            case (?bit) { bit };
            case null {
              Runtime.trap("AsyncRandom.bool(): generator produced empty Blob")
            }
          }
        }
      }
    };

    /// Random `Nat8` value in the range [0, 256).
    public func byte() : async* Nat8 {
      switch (iter.next()) {
        case (?byte) { byte };
        case null {
          iter := (await* generator()).vals();
          switch (iter.next()) {
            case (?byte) { byte };
            case null {
              Runtime.trap("AsyncRandom.byte(): generator produced empty Blob")
            }
          }
        }
      }
    };

    /// Random `Float` value in the range [0, 1).
    public func float() : async* Float {
      todo()
    };

    public func intRange(from : Int, toExclusive : Int) : async* Int {
      if (from > toExclusive) {
        Debug.trap("AsyncRandom.intRange(): from > toExclusive")
      };
      todo()
    };

    public func natRange(from : Nat, toExclusive : Nat) : async* Nat {
      if (from > toExclusive) {
        Debug.trap("AsyncRandom.natRange(): from > toExclusive")
      };
      todo()
    };

  };

}
