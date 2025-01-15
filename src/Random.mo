/// Random number generation

import Iter "Iter";
import { todo; unreachable } "Debug";

module {

  let rawRand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = rawRand;

  /// Opinionated choice of PRNG from a given seed.
  public func new(seed : Blob) : Random {
    todo()
  };

  /// Uses entropy from the management canister with automatic resupply.
  public func newAsync() : AsyncRandom {
    todo()
  };

  public class Random(generator : () -> Blob) {

    /// Random choice between `true` and `false`.
    public func bool() : Bool {
      todo()
    };

    /// Random `Nat8` value in the range [0, 256).
    public func byte() : Nat8 {
      todo()
    };

    /// Random `Float` value in the range [0, 1).
    /// The resolution is maximal (i.e. all relevant mantissa bits are randomized).
    public func float() : Float {
      todo()
    };

    public func intRange(min : Int, maxExclusive : Int) : Int {
      todo()
    };

    public func natRange(min : Nat, maxExclusive : Nat) : Nat {
      todo()
    };

  };

  public class AsyncRandom(generator : () -> async* Blob) {

    public func bool() : async* Bool {
      todo()
    };

    public func byte() : async* Nat8 {
      todo()
    };

    public func float() : async* Float {
      todo()
    };

    public func natRange(min : Nat, maxExclusive : Nat) : async* Nat {
      todo()
    };

    public func intRange(min : Int, maxExclusive : Int) : async* Int {
      todo()
    };

  };

}
