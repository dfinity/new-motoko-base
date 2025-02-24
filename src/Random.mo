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

module {

  let rawRand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = rawRand;

  /// Opinionated choice of PRNG from a given seed.
  public func new(seed : Blob) : Random {
    // Use the seed as initial entropy
    var entropy = seed;

    func nextBlob() : Blob {
      // Simple xorshift-like algorithm for demonstration
      let bytes = entropy.vals();
      var result = "";
      for (b in bytes) {
        // Simple PRNG using multiplication and addition
        let x = Nat8.toNat(b);
        let mixed = (x * 1103515245 + 12345) % 256;
        result := result # Text.fromChar(Char.fromNat32(Nat32.fromNat(mixed)))
      };
      entropy := Text.encodeUtf8(result);
      entropy
    };

    Random(nextBlob)
  };

  /// Uses entropy from the management canister with automatic resupply.
  public func newAsync() : AsyncRandom {
    // Convert shared function to async* function
    func asyncRand() : async* Blob {
      await rawRand()
    };
    AsyncRandom(asyncRand)
  };

  public class Random(generator : () -> Blob) {
    var iter : Iter.Iter<Nat8> = Iter.empty();

    /// Random choice between `true` and `false`.
    public func bool() : Bool {
      byte() % 2 == 0
    };

    /// Random `Nat8` value in the range [0, 256).
    public func byte() : Nat8 {
      switch (iter.next()) {
        case (?byte) { byte };
        case null {
          iter := generator().vals();
          switch (iter.next()) {
            case (?byte) { byte };
            case null { Runtime.trap("Random generator produced empty Blob") }
          }
        }
      }
    };

    /// Random `Float` value in the range [0, 1).
    /// The resolution is maximal (i.e. all relevant mantissa bits are randomized).
    public func float() : Float {
      var acc : Nat = 0;
      var i = 0;
      label l loop {
        if (i >= 8) break l;
        acc := Nat.bitshiftLeft(acc, 8) + Nat8.toNat(byte());
        i += 1
      };
      Float.fromInt(acc) / Float.fromInt(Nat.pow(2, 64))
    };

    public func intRange(from : Int, toExclusive : Int) : Int {
      if (from >= toExclusive) {
        Debug.trap("Random.intRange: from >= toExclusive")
      };
      let range = toExclusive - from;
      from + Int.abs(range) * Int.fromNat(Nat8.toNat(byte())) / 256
    };

    public func natRange(from : Nat, toExclusive : Nat) : Nat {
      if (from >= toExclusive) {
        Debug.trap("Random.natRange: from >= toExclusive")
      };
      let range = toExclusive - from : Nat;
      from + range * Nat8.toNat(byte()) / 256
    };

  };

  public class AsyncRandom(generator : () -> async* Blob) {
    var iter = Iter.empty<Nat8>();

    /// Random `Nat8` value in the range [0, 256).
    public func byte() : async* Nat8 {
      switch (iter.next()) {
        case (?byte) { byte };
        case null {
          iter := (await* generator()).vals();
          switch (iter.next()) {
            case (?byte) { byte };
            case null { Runtime.trap("Random generator produced empty Blob") }
          }
        }
      }
    };

    /// Random choice between `true` and `false`.
    public func bool() : async* Bool {
      (await* byte()) % 2 == 0
    };

    /// Random `Float` value in the range [0, 1).
    /// The resolution is maximal (i.e. all relevant mantissa bits are randomized).
    public func float() : async* Float {
      var acc : Nat = 0;
      var i = 0;
      label l loop {
        if (i >= 8) break l;
        acc := Nat.bitshiftLeft(acc, 8) + Nat8.toNat(await* byte());
        i += 1
      };
      Float.fromInt(acc) / Float.fromInt(Nat.pow(2, 64))
    };

    public func intRange(from : Int, toExclusive : Int) : async* Int {
      if (from >= toExclusive) {
        Debug.trap("AsyncRandom.intRange: from >= toExclusive")
      };
      let range = toExclusive - from;
      from + Int.abs(range) * Int.fromNat(Nat8.toNat(await* byte())) / 256
    };

    public func natRange(from : Nat, toExclusive : Nat) : async* Nat {
      if (from >= toExclusive) {
        Debug.trap("AsyncRandom.natRange: from >= toExclusive")
      };
      let range = toExclusive - from : Nat;
      from + range * Nat8.toNat(await* byte()) / 256
    };

  };

}
