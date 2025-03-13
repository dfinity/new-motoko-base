/// Random number generation.

import Array "Array";
import VarArray "VarArray";
import Nat8 "Nat8";
import Nat64 "Nat64";
import Int "Int";
import Nat "Nat";
import Blob "Blob";
import Iter "Iter";
import Runtime "Runtime";
import PRNG "internal/PRNG";

module {

  let rawRand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = rawRand;

  /// Creates a fast pseudo-random number generator using the SFC64 algorithm.
  /// This provides statistical randomness suitable for simulations and testing,
  /// but should not be used for cryptographic purposes.
  /// The seed blob's first 8 bytes are used to initialize the PRNG.
  public func fast(seed : Nat64) : Random {
    let prng = PRNG.sfc64a();
    prng.init(seed);
    fromGenerator(
      func() {
        // Generate 8 bytes directly from a single 64-bit number
        let n = prng.next();
        // TODO: optimize using Array.tabulate or even better: a new primitive
        let bytes = VarArray.repeat<Nat8>(0, 8);
        bytes[0] := Nat8.fromNat(Nat64.toNat(n & 0xFF));
        bytes[1] := Nat8.fromNat(Nat64.toNat((n >> 8) & 0xFF));
        bytes[2] := Nat8.fromNat(Nat64.toNat((n >> 16) & 0xFF));
        bytes[3] := Nat8.fromNat(Nat64.toNat((n >> 24) & 0xFF));
        bytes[4] := Nat8.fromNat(Nat64.toNat((n >> 32) & 0xFF));
        bytes[5] := Nat8.fromNat(Nat64.toNat((n >> 40) & 0xFF));
        bytes[6] := Nat8.fromNat(Nat64.toNat((n >> 48) & 0xFF));
        bytes[7] := Nat8.fromNat(Nat64.toNat((n >> 56) & 0xFF));
        Blob.fromArray(Array.fromVarArray(bytes))
      }
    )
  };

  /// Creates a random number generator suitable for cryptography
  /// using entropy from the ICP management canister with automatic resupply.
  public func crypto() : AsyncRandom {
    fromAsyncGenerator(func() : async* Blob { await rawRand() })
  };

  public func fromGenerator(generator : () -> Blob) : Random {
    var iter : Iter.Iter<Nat8> = Iter.empty();
    let bitIter : Iter.Iter<Bool> = object {
      var mask = 0x00 : Nat8;
      var byte = 0x00 : Nat8;
      public func next() : ?Bool {
        if (0 : Nat8 == mask) {
          switch (iter.next()) {
            case null null;
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
    Random({
      nextBit = func() {
        switch (bitIter.next()) {
          case (?bit) { bit };
          case null {
            iter := generator().vals();
            switch (bitIter.next()) {
              case (?bit) { bit };
              case null Runtime.trap("Random.bool(): generator produced empty Blob")
            }
          }
        }
      };
      nextByte = func() {
        switch (iter.next()) {
          case (?byte) { byte };
          case null {
            iter := generator().vals();
            switch (iter.next()) {
              case (?byte) { byte };
              case null Runtime.trap("Random.nat8(): generator produced empty Blob")
            }
          }
        }
      }
    })
  };

  public func fromAsyncGenerator(generator : () -> async* Blob) : AsyncRandom {
    var iter : Iter.Iter<Nat8> = Iter.empty();
    let bitIter : Iter.Iter<Bool> = object {
      var mask = 0x00 : Nat8;
      var byte = 0x00 : Nat8;
      public func next() : ?Bool {
        if (0 : Nat8 == mask) {
          switch (iter.next()) {
            case null null;
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
    AsyncRandom({
      nextBit = func() : async* Bool {
        switch (bitIter.next()) {
          case (?bit) { bit };
          case null {
            iter := (await* generator()).vals();
            switch (bitIter.next()) {
              case (?bit) { bit };
              case null Runtime.trap("Random.bool(): generator produced empty Blob")
            }
          }
        }
      };
      nextByte = func() : async* Nat8 {
        switch (iter.next()) {
          case (?byte) { byte };
          case null {
            iter := (await* generator()).vals();
            switch (iter.next()) {
              case (?byte) { byte };
              case null Runtime.trap("Random.nat8(): generator produced empty Blob")
            }
          }
        }
      }
    })
  };

  public class Random({
    nextBit : () -> Bool;
    nextByte : () -> Nat8
  }) {
    /// Random choice between `true` and `false`.
    public let bool = nextBit;

    /// Random `Nat8` value in the range [0, 256).
    public let nat8 = nextByte;

    // Helper function which returns a uniformly sampled `Nat64` in the range `[0, max]`.
    // Uses rejection sampling to ensure uniform distribution even when the range
    // doesn't divide evenly into 2^64. This avoids modulo bias that would occur
    // from simply taking the modulo of a random 64-bit number.
    func uniform64(max : Nat64) : Nat64 {
      if (max == 0) {
        return 0
      };
      if (max == Nat64.maxValue) {
        return nat64()
      };
      let toExclusive = max + 1;
      // 2^64 - (2^64 % toExclusive) = (2^64-1) - (2^64-1 % toExclusive):
      let cutoff = Nat64.maxValue - (Nat64.maxValue % toExclusive);
      // 2^64 / toExclusive, with toExclusive > 1:
      let multiple = Nat64.fromNat(/* 2^64 */ 0x10000000000000000 / Nat64.toNat(toExclusive));
      loop {
        // Build up a random Nat64 from bytes
        var number = nat64();
        // If number is below cutoff, we can use it
        if (number < cutoff) {
          // Scale down to desired range
          return number / multiple
        };
        // Otherwise reject and try again
      }
    };

    public func nat64() : Nat64 {
      // prettier-ignore
      (Nat64.fromNat(Nat8.toNat(nat8())) << 56) |
      (Nat64.fromNat(Nat8.toNat(nat8())) << 48) |
      (Nat64.fromNat(Nat8.toNat(nat8())) << 40) |
      (Nat64.fromNat(Nat8.toNat(nat8())) << 32) |
      (Nat64.fromNat(Nat8.toNat(nat8())) << 24) |
      (Nat64.fromNat(Nat8.toNat(nat8())) << 16) |
      (Nat64.fromNat(Nat8.toNat(nat8())) << 8) |
      (Nat64.fromNat(Nat8.toNat(nat8())))
    };

    public func nat64Range(fromInclusive : Nat64, toExclusive : Nat64) : Nat64 {
      if (fromInclusive >= toExclusive) {
        Runtime.trap("Random.nat64Range(): fromInclusive >= toExclusive")
      };
      uniform64(toExclusive - fromInclusive - 1) + fromInclusive
    };

    public func natRange(fromInclusive : Nat, toExclusive : Nat) : Nat {
      if (fromInclusive >= toExclusive) {
        Runtime.trap("Random.natRange(): fromInclusive >= toExclusive")
      };
      Nat64.toNat(uniform64(Nat64.fromNat(toExclusive - fromInclusive - 1))) + fromInclusive
    };

    public func intRange(fromInclusive : Int, toExclusive : Int) : Int {
      if (fromInclusive >= toExclusive) {
        Runtime.trap("Random.intRange(): fromInclusive >= toExclusive")
      };
      Nat64.toNat(uniform64(Nat64.fromNat(Nat.fromInt(toExclusive - fromInclusive - 1)))) + fromInclusive
    };

  };

  public class AsyncRandom({
    nextBit : () -> async* Bool;
    nextByte : () -> async* Nat8
  }) {
    /// Random choice between `true` and `false`.
    public let bool = nextBit;

    /// Random `Nat8` value in the range [0, 256).
    public let nat8 = nextByte;

    // Helper function which returns a uniformly sampled `Nat64` in the range `[0, max]`.
    // Uses rejection sampling to ensure uniform distribution even when the range
    // doesn't divide evenly into 2^64. This avoids modulo bias that would occur
    // from simply taking the modulo of a random 64-bit number.
    func uniform64(max : Nat64) : async* Nat64 {
      if (max == 0) {
        return 0
      };
      if (max == Nat64.maxValue) {
        return await* nat64()
      };
      let toExclusive = max + 1;
      // 2^64 - (2^64 % toExclusive) = (2^64-1) - (2^64-1 % toExclusive):
      let cutoff = Nat64.maxValue - (Nat64.maxValue % toExclusive);
      // 2^64 / toExclusive, with toExclusive > 1:
      let multiple = Nat64.fromNat(/* 2^64 */ 0x10000000000000000 / Nat64.toNat(toExclusive));
      loop {
        // Build up a random Nat64 from bytes
        var number = await* nat64();
        // If number is below cutoff, we can use it
        if (number < cutoff) {
          // Scale down to desired range
          return number / multiple
        };
        // Otherwise reject and try again
      }
    };

    public func nat64() : async* Nat64 {
      // prettier-ignore
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 56) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 48) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 40) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 32) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 24) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 16) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())) << 8) |
      (Nat64.fromNat(Nat8.toNat(await* nat8())))
    };

    public func nat64Range(fromInclusive : Nat64, toExclusive : Nat64) : async* Nat64 {
      if (fromInclusive >= toExclusive) {
        Runtime.trap("Random.nat64Range(): fromInclusive >= toExclusive")
      };
      (await* uniform64(toExclusive - fromInclusive - 1)) + fromInclusive
    };

    public func natRange(fromInclusive : Nat, toExclusive : Nat) : async* Nat {
      if (fromInclusive >= toExclusive) {
        Runtime.trap("Random.natRange(): fromInclusive >= toExclusive")
      };
      Nat64.toNat(await* uniform64(Nat64.fromNat(toExclusive - fromInclusive - 1))) + fromInclusive
    };

    public func intRange(fromInclusive : Int, toExclusive : Int) : async* Int {
      if (fromInclusive >= toExclusive) {
        Runtime.trap("Random.intRange(): fromInclusive >= toExclusive")
      };
      Nat64.toNat(await* uniform64(Nat64.fromNat(Nat.fromInt(toExclusive - fromInclusive - 1)))) + fromInclusive
    };

  };

}
