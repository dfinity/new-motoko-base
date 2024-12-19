/// A module for obtaining randomness on the Internet Computer.

import Iter "Iter";
import { nyi = todo } "Debug";

module {

  let rawRand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = rawRand;

  /// Opinionated choice of PRNG from a given seed.
  public func new(seed : Blob) : Random {
    todo()
  };

  /// Uses entropy from the management canister with automatic resupply.
  public func newAsync() : AsyncRandom = AsyncRandom(rawRand);

  public class Random(generator : () -> Nat8) {

    public func bool() : Bool {
      todo()
    };

    public func byte() : Nat8 {
      todo()
    };

    public func intRange(min : Int, maxExclusive : Int) : Int {
      todo()
    };

    public func natRange(min : Nat, maxExclusive : Nat) : Nat {
      todo()
    };

  };

  public class AsyncRandom(generator : shared () -> async Blob) {

    public func bool() : async Bool {
      todo()
    };

    public func byte() : async Nat8 {
      todo()
    };

    public func natRange(min : Nat, maxExclusive : Nat) : async Nat {
      todo()
    };

    public func intRange(min : Int, maxExclusive : Int) : async Int {
      todo()
    };

  };

}
