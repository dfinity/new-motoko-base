/// Random number generation

import Iter "Iter";
import Prim "mo:⛔";

module {

  let rawRand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = rawRand;

  // Remove `Finite` class?

  // TODO: `Async` class
}
