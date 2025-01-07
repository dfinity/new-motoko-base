/// 32-bit unsigned integers

import Nat "Nat";
import Iter "IterType";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Nat32 = Prim.Types.Nat32;

  public let maximumValue = 4294967295 : Nat32;

  public let toNat : Nat32 -> Nat = Prim.nat32ToNat;

  public let fromNat : Nat -> Nat32 = Prim.natToNat32;

  public func fromNat16(x : Nat16) : Nat32 {
    Prim.nat16ToNat32(x)
  };

  public func toNat16(x : Nat32) : Nat16 {
    Prim.nat32ToNat16(x)
  };

  public func fromNat64(x : Nat64) : Nat32 {
    Prim.nat64ToNat32(x)
  };

  public func toNat64(x : Nat32) : Nat64 {
    Prim.nat32ToNat64(x)
  };

  public let fromIntWrap : Int -> Nat32 = Prim.intToNat32Wrap;

  public func toText(x : Nat32) : Text {
    Nat.toText(toNat(x))
  };

  public func min(x : Nat32, y : Nat32) : Nat32 {
    if (x < y) { x } else { y }
  };

  public func max(x : Nat32, y : Nat32) : Nat32 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Nat32, y : Nat32) : Bool { x == y };

  public func notEqual(x : Nat32, y : Nat32) : Bool { x != y };

  public func less(x : Nat32, y : Nat32) : Bool { x < y };

  public func lessOrEqual(x : Nat32, y : Nat32) : Bool { x <= y };

  public func greater(x : Nat32, y : Nat32) : Bool { x > y };

  public func greaterOrEqual(x : Nat32, y : Nat32) : Bool { x >= y };

  public func compare(x : Nat32, y : Nat32) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func add(x : Nat32, y : Nat32) : Nat32 { x + y };

  public func sub(x : Nat32, y : Nat32) : Nat32 { x - y };

  public func mul(x : Nat32, y : Nat32) : Nat32 { x * y };

  public func div(x : Nat32, y : Nat32) : Nat32 { x / y };

  public func rem(x : Nat32, y : Nat32) : Nat32 { x % y };

  public func pow(x : Nat32, y : Nat32) : Nat32 { x ** y };

  public func bitnot(x : Nat32) : Nat32 { ^x };

  public func bitand(x : Nat32, y : Nat32) : Nat32 { x & y };

  public func bitor(x : Nat32, y : Nat32) : Nat32 { x | y };

  public func bitxor(x : Nat32, y : Nat32) : Nat32 { x ^ y };

  public func bitshiftLeft(x : Nat32, y : Nat32) : Nat32 { x << y };

  public func bitshiftRight(x : Nat32, y : Nat32) : Nat32 { x >> y };

  public func bitrotLeft(x : Nat32, y : Nat32) : Nat32 { x <<> y };

  public func bitrotRight(x : Nat32, y : Nat32) : Nat32 { x <>> y };

  public func bittest(x : Nat32, p : Nat) : Bool {
    Prim.btstNat32(x, Prim.natToNat32(p))
  };

  public func bitset(x : Nat32, p : Nat) : Nat32 {
    x | (1 << Prim.natToNat32(p))
  };

  public func bitclear(x : Nat32, p : Nat) : Nat32 {
    x & ^(1 << Prim.natToNat32(p))
  };

  public func bitflip(x : Nat32, p : Nat) : Nat32 {
    x ^ (1 << Prim.natToNat32(p))
  };

  public let bitcountNonZero : (x : Nat32) -> Nat32 = Prim.popcntNat32;

  public let bitcountLeadingZero : (x : Nat32) -> Nat32 = Prim.clzNat32;

  public let bitcountTrailingZero : (x : Nat32) -> Nat32 = Prim.ctzNat32;

  public func addWrap(x : Nat32, y : Nat32) : Nat32 { x +% y };

  public func subWrap(x : Nat32, y : Nat32) : Nat32 { x -% y };

  public func mulWrap(x : Nat32, y : Nat32) : Nat32 { x *% y };

  public func powWrap(x : Nat32, y : Nat32) : Nat32 { x **% y };

  public class range(fromInclusive : Nat32, toExclusive : Nat32) {
    todo()
  };

  public class rangeInclusive(from : Nat32, to : Nat32) {
    todo()
  };

  public func allValues() : Iter.Iter<Nat32> {
    todo()
  };

}
