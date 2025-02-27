/// Random number generation.

import Nat8 "Nat8";
import Nat64 "Nat64";
import Int "Int";
import Nat "Nat";
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
    public func nat8() : Nat8 {
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

    // Helper function which returns a uniformly sampled `Nat64` in the range `[0, toExclusive)`.
    func uniform64(toExclusive : Nat64) : Nat64 {
      if (toExclusive <= 1) {
        return 0
      };
      // 2^64 - (2^64 % toExclusive) = (2^64-1) - (2^64-1 % toExclusive):
      let cutOff = Nat64.maxValue - (Nat64.maxValue % toExclusive);
      // 2^64 / toExclusive, with toExclusive > 1:
      let multiple = Nat64.fromNat(Nat.pow(2, 64) / Nat64.toNat(toExclusive));
      loop {
        // Build up a random Nat64 from bytes
        var number : Nat64 = 0;
        for (_ in Nat8.range(0, 8)) {
          number := (number << 8) | Nat64.fromNat(Nat8.toNat(nat8()))
        };
        // If number is below cutoff, we can use it
        if (number < cutOff) {
          // Scale down to desired range
          return number / multiple
        };
        // Otherwise reject and try again
      }
    };

    public func nat64() : Nat64 {
      uniform64(Nat64.maxValue)
    };

    public func nat64Range(from : Nat64, toExclusive : Nat64) : Nat64 {
      if (from > toExclusive) {
        Runtime.trap("Random.nat64Range(): from > toExclusive")
      };
      uniform64(toExclusive - from) + from
    };

    public func intRange(from : Int, toExclusive : Int) : Int {
      switch (Nat.fromInt(toExclusive - from)) {
        case (?range) Nat64.toNat(uniform64(Nat64.fromNat(range))) + from;
        case _ Runtime.trap("Random.intRange(): from > toExclusive")
      }
    };

    public func natRange(from : Nat, toExclusive : Nat) : Nat {
      if (from > toExclusive) {
        Runtime.trap("Random.natRange(): from > toExclusive")
      };
      Nat64.toNat(uniform64(Nat64.fromNat(toExclusive - from))) + from
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
    public func nat8() : async* Nat8 {
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

    public func int(from : Int, toExclusive : Int) : async* Int {
      if (from > toExclusive) {
        Runtime.trap("AsyncRandom.intRange(): from > toExclusive")
      };
      todo()
    };

    public func nat(from : Nat, toExclusive : Nat) : async* Nat {
      if (from > toExclusive) {
        Runtime.trap("AsyncRandom.natRange(): from > toExclusive")
      };
      todo()
    };

  };

}
