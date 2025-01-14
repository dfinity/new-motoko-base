/// 32-bit signed integers

import Int "Int";
import Iter "IterType";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Int32 = Prim.Types.Int32;

  public let minimumValue = -2_147_483_648 : Int32;

  public let maximumValue = 2_147_483_647 : Int32;

  public let toInt : Int32 -> Int = Prim.int32ToInt;

  public let fromInt : Int -> Int32 = Prim.intToInt32;

  public let fromIntWrap : Int -> Int32 = Prim.intToInt32Wrap;

  public let fromInt16 : Int16 -> Int32 = Prim.int16ToInt32;

  public let toInt16 : Int32 -> Int16 = Prim.int32ToInt16;

  public let fromInt64 : Int64 -> Int32 = Prim.int64ToInt32;

  public let toInt64 : Int32 -> Int64 = Prim.int32ToInt64;

  public let fromNat32 : Nat32 -> Int32 = Prim.nat32ToInt32;

  public let toNat32 : Int32 -> Nat32 = Prim.int32ToNat32;

  public func toText(x : Int32) : Text {
    Int.toText(toInt(x))
  };

  public func abs(x : Int32) : Int32 {
    fromInt(Int.abs(toInt(x)))
  };

  public func min(x : Int32, y : Int32) : Int32 {
    if (x < y) { x } else { y }
  };

  public func max(x : Int32, y : Int32) : Int32 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Int32, y : Int32) : Bool { x == y };

  public func notEqual(x : Int32, y : Int32) : Bool { x != y };

  public func less(x : Int32, y : Int32) : Bool { x < y };

  public func lessOrEqual(x : Int32, y : Int32) : Bool { x <= y };

  public func greater(x : Int32, y : Int32) : Bool { x > y };

  public func greaterOrEqual(x : Int32, y : Int32) : Bool { x >= y };

  public func compare(x : Int32, y : Int32) : { #Less; #Equal; #Greater } {
    if (x < y) { #Less } else if (x == y) { #Equal } else { #Greater }
  };

  public func neg(x : Int32) : Int32 { -x };

  public func add(x : Int32, y : Int32) : Int32 { x + y };

  public func sub(x : Int32, y : Int32) : Int32 { x - y };

  public func mul(x : Int32, y : Int32) : Int32 { x * y };

  public func div(x : Int32, y : Int32) : Int32 { x / y };

  public func rem(x : Int32, y : Int32) : Int32 { x % y };

  public func pow(x : Int32, y : Int32) : Int32 { x ** y };

  public func bitnot(x : Int32) : Int32 { ^x };

  public func bitand(x : Int32, y : Int32) : Int32 { x & y };

  public func bitor(x : Int32, y : Int32) : Int32 { x | y };

  public func bitxor(x : Int32, y : Int32) : Int32 { x ^ y };

  public func bitshiftLeft(x : Int32, y : Int32) : Int32 { x << y };

  public func bitshiftRight(x : Int32, y : Int32) : Int32 { x >> y };

  public func bitrotLeft(x : Int32, y : Int32) : Int32 { x <<> y };

  public func bitrotRight(x : Int32, y : Int32) : Int32 { x <>> y };

  public func bittest(x : Int32, p : Nat) : Bool {
    Prim.btstInt32(x, Prim.intToInt32(p))
  };

  public func bitset(x : Int32, p : Nat) : Int32 {
    x | (1 << Prim.intToInt32(p))
  };

  public func bitclear(x : Int32, p : Nat) : Int32 {
    x & ^(1 << Prim.intToInt32(p))
  };

  public func bitflip(x : Int32, p : Nat) : Int32 {
    x ^ (1 << Prim.intToInt32(p))
  };

  public let bitcountNonZero : (x : Int32) -> Int32 = Prim.popcntInt32;

  public let bitcountLeadingZero : (x : Int32) -> Int32 = Prim.clzInt32;

  public let bitcountTrailingZero : (x : Int32) -> Int32 = Prim.ctzInt32;

  public func addWrap(x : Int32, y : Int32) : Int32 { x +% y };

  public func subWrap(x : Int32, y : Int32) : Int32 { x -% y };

  public func mulWrap(x : Int32, y : Int32) : Int32 { x *% y };

  public func powWrap(x : Int32, y : Int32) : Int32 { x **% y };

  public func range(fromInclusive : Int32, toExclusive : Int32) : Iter.Iter<Int32> {
    todo()
  };

  public func rangeInclusive(from : Int32, to : Int32) : Iter.Iter<Int32> {
    todo()
  };

  public func allValues() : Iter.Iter<Int32> {
    todo()
  };

}
