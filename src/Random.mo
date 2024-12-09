/// A module for obtaining randomness on the Internet Computer.

import Iter "Iter";
import Prim "mo:⛔";

module {

  let raw_rand = (actor "aaaaa-aa" : actor { raw_rand : () -> async Blob }).raw_rand;

  public let blob : shared () -> async Blob = raw_rand;

  // Remove `Finite` class?

  // TODO: `Async` class
}
