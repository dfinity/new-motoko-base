/// 64-bit unsigned integers

import Nat "Nat";
import Iter "IterType";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Nat64 = Prim.Types.Nat64;

  public let maxValue : Nat64 = 18446744073709551615;

  public let toNat : Nat64 -> Nat = Prim.nat64ToNat;

  public let fromNat : Nat -> Nat64 = Prim.natToNat64;

  public func fromNat32(x : Nat32) : Nat64 {
    Prim.nat32ToNat64(x)
  };

  public func toNat32(x : Nat64) : Nat32 {
    Prim.nat64ToNat32(x)
  };

  public let fromIntWrap : Int -> Nat64 = Prim.intToNat64Wrap;

  public func toText(x : Nat64) : Text {
    Nat.toText(toNat(x))
  };

  public func min(x : Nat64, y : Nat64) : Nat64 {
    if (x < y) { x } else { y }
  };

  public func max(x : Nat64, y : Nat64) : Nat64 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Nat64, y : Nat64) : Bool { x == y };

  public func notEqual(x : Nat64, y : Nat64) : Bool { x != y };

  public func less(x : Nat64, y : Nat64) : Bool { x < y };

  public func lessOrEqual(x : Nat64, y : Nat64) : Bool { x <= y };

  public func greater(x : Nat64, y : Nat64) : Bool { x > y };

  public func greaterOrEqual(x : Nat64, y : Nat64) : Bool { x >= y };

  public func compare(x : Nat64, y : Nat64) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func add(x : Nat64, y : Nat64) : Nat64 { x + y };

  public func sub(x : Nat64, y : Nat64) : Nat64 { x - y };

  public func mul(x : Nat64, y : Nat64) : Nat64 { x * y };

  public func div(x : Nat64, y : Nat64) : Nat64 { x / y };

  public func rem(x : Nat64, y : Nat64) : Nat64 { x % y };

  public func pow(x : Nat64, y : Nat64) : Nat64 { x ** y };

  public func bitnot(x : Nat64) : Nat64 { ^x };

  public func bitand(x : Nat64, y : Nat64) : Nat64 { x & y };

  public func bitor(x : Nat64, y : Nat64) : Nat64 { x | y };

  public func bitxor(x : Nat64, y : Nat64) : Nat64 { x ^ y };

  public func bitshiftLeft(x : Nat64, y : Nat64) : Nat64 { x << y };

  public func bitshiftRight(x : Nat64, y : Nat64) : Nat64 { x >> y };

  public func bitrotLeft(x : Nat64, y : Nat64) : Nat64 { x <<> y };

  public func bitrotRight(x : Nat64, y : Nat64) : Nat64 { x <>> y };

  public func bittest(x : Nat64, p : Nat) : Bool {
    Prim.btstNat64(x, Prim.natToNat64(p))
  };

  public func bitset(x : Nat64, p : Nat) : Nat64 {
    x | (1 << Prim.natToNat64(p))
  };

  public func bitclear(x : Nat64, p : Nat) : Nat64 {
    x & ^(1 << Prim.natToNat64(p))
  };

  public func bitflip(x : Nat64, p : Nat) : Nat64 {
    x ^ (1 << Prim.natToNat64(p))
  };

  public let bitcountNonZero : (x : Nat64) -> Nat64 = Prim.popcntNat64;

  public let bitcountLeadingZero : (x : Nat64) -> Nat64 = Prim.clzNat64;

  public let bitcountTrailingZero : (x : Nat64) -> Nat64 = Prim.ctzNat64;

  public func addWrap(x : Nat64, y : Nat64) : Nat64 { x +% y };

  public func subWrap(x : Nat64, y : Nat64) : Nat64 { x -% y };

  public func mulWrap(x : Nat64, y : Nat64) : Nat64 { x *% y };

  public func powWrap(x : Nat64, y : Nat64) : Nat64 { x **% y };

  public func range(fromInclusive : Nat64, toExclusive : Nat64) : Iter.Iter<Nat64> {
    todo()
  };

  public func rangeInclusive(from : Nat64, to : Nat64) : Iter.Iter<Nat64> {
    todo()
  };

  public func allValues() : Iter.Iter<Nat64> {
    todo()
  };

}
