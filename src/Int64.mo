/// 64-bit signed integers

import Int "Int";
import Iter "IterType";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Int64 = Prim.Types.Int64;

  public let minimumValue = -9_223_372_036_854_775_808 : Int64;

  public let maximumValue = 9_223_372_036_854_775_807 : Int64;

  public let toInt : Int64 -> Int = Prim.int64ToInt;

  public let fromInt : Int -> Int64 = Prim.intToInt64;

  public let fromInt32 : Int32 -> Int64 = Prim.int32ToInt64;

  public let toInt32 : Int64 -> Int32 = Prim.int64ToInt32;

  public let fromIntWrap : Int -> Int64 = Prim.intToInt64Wrap;

  public let fromNat64 : Nat64 -> Int64 = Prim.nat64ToInt64;

  public let toNat64 : Int64 -> Nat64 = Prim.int64ToNat64;

  public func toText(x : Int64) : Text {
    Int.toText(toInt(x))
  };

  public func abs(x : Int64) : Int64 {
    fromInt(Int.abs(toInt(x)))
  };

  public func min(x : Int64, y : Int64) : Int64 {
    if (x < y) { x } else { y }
  };

  public func max(x : Int64, y : Int64) : Int64 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Int64, y : Int64) : Bool { x == y };

  public func notEqual(x : Int64, y : Int64) : Bool { x != y };

  public func less(x : Int64, y : Int64) : Bool { x < y };

  public func lessOrEqual(x : Int64, y : Int64) : Bool { x <= y };

  public func greater(x : Int64, y : Int64) : Bool { x > y };

  public func greaterOrEqual(x : Int64, y : Int64) : Bool { x >= y };

  public func compare(x : Int64, y : Int64) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func neg(x : Int64) : Int64 { -x };

  public func add(x : Int64, y : Int64) : Int64 { x + y };

  public func sub(x : Int64, y : Int64) : Int64 { x - y };

  public func mul(x : Int64, y : Int64) : Int64 { x * y };

  public func div(x : Int64, y : Int64) : Int64 { x / y };

  public func rem(x : Int64, y : Int64) : Int64 { x % y };

  public func pow(x : Int64, y : Int64) : Int64 { x ** y };

  public func bitnot(x : Int64) : Int64 { ^x };

  public func bitand(x : Int64, y : Int64) : Int64 { x & y };

  public func bitor(x : Int64, y : Int64) : Int64 { x | y };

  public func bitxor(x : Int64, y : Int64) : Int64 { x ^ y };

  public func bitshiftLeft(x : Int64, y : Int64) : Int64 { x << y };

  public func bitshiftRight(x : Int64, y : Int64) : Int64 { x >> y };

  public func bitrotLeft(x : Int64, y : Int64) : Int64 { x <<> y };

  public func bitrotRight(x : Int64, y : Int64) : Int64 { x <>> y };

  public func bittest(x : Int64, p : Nat) : Bool {
    Prim.btstInt64(x, Prim.intToInt64(p))
  };

  public func bitset(x : Int64, p : Nat) : Int64 {
    x | (1 << Prim.intToInt64(p))
  };

  public func bitclear(x : Int64, p : Nat) : Int64 {
    x & ^(1 << Prim.intToInt64(p))
  };

  public func bitflip(x : Int64, p : Nat) : Int64 {
    x ^ (1 << Prim.intToInt64(p))
  };

  public let bitcountNonZero : (x : Int64) -> Int64 = Prim.popcntInt64;

  public let bitcountLeadingZero : (x : Int64) -> Int64 = Prim.clzInt64;

  public let bitcountTrailingZero : (x : Int64) -> Int64 = Prim.ctzInt64;

  public func addWrap(x : Int64, y : Int64) : Int64 { x +% y };

  public func subWrap(x : Int64, y : Int64) : Int64 { x -% y };

  public func mulWrap(x : Int64, y : Int64) : Int64 { x *% y };

  public func powWrap(x : Int64, y : Int64) : Int64 { x **% y };

  public func allValues() : Iter.Iter<Bool> {
    todo()
  };
}
