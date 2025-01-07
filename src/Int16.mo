/// 16-bit signed integers

import Int "Int";
import Iter "IterType";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Int16 = Prim.Types.Int16;

  public let minimumValue = -32_768 : Int16;

  public let maximumValue = 32_767 : Int16;

  public let toInt : Int16 -> Int = Prim.int16ToInt;

  public let fromInt : Int -> Int16 = Prim.intToInt16;

  public let fromIntWrap : Int -> Int16 = Prim.intToInt16Wrap;

  public let fromInt8 : Int8 -> Int16 = Prim.int8ToInt16;

  public let toInt8 : Int16 -> Int8 = Prim.int16ToInt8;

  public let fromInt32 : Int32 -> Int16 = Prim.int32ToInt16;

  public let toInt32 : Int16 -> Int32 = Prim.int16ToInt32;

  public let fromNat16 : Nat16 -> Int16 = Prim.nat16ToInt16;

  public let toNat16 : Int16 -> Nat16 = Prim.int16ToNat16;

  public func toText(x : Int16) : Text {
    Int.toText(toInt(x))
  };

  public func abs(x : Int16) : Int16 {
    fromInt(Int.abs(toInt(x)))
  };

  public func min(x : Int16, y : Int16) : Int16 {
    if (x < y) { x } else { y }
  };

  public func max(x : Int16, y : Int16) : Int16 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Int16, y : Int16) : Bool { x == y };

  public func notEqual(x : Int16, y : Int16) : Bool { x != y };

  public func less(x : Int16, y : Int16) : Bool { x < y };

  public func lessOrEqual(x : Int16, y : Int16) : Bool { x <= y };

  public func greater(x : Int16, y : Int16) : Bool { x > y };

  public func greaterOrEqual(x : Int16, y : Int16) : Bool { x >= y };

  public func compare(x : Int16, y : Int16) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func neg(x : Int16) : Int16 { -x };

  public func add(x : Int16, y : Int16) : Int16 { x + y };

  public func sub(x : Int16, y : Int16) : Int16 { x - y };

  public func mul(x : Int16, y : Int16) : Int16 { x * y };

  public func div(x : Int16, y : Int16) : Int16 { x / y };

  public func rem(x : Int16, y : Int16) : Int16 { x % y };

  public func pow(x : Int16, y : Int16) : Int16 { x ** y };

  public func bitnot(x : Int16) : Int16 { ^x };

  public func bitand(x : Int16, y : Int16) : Int16 { x & y };

  public func bitor(x : Int16, y : Int16) : Int16 { x | y };

  public func bitxor(x : Int16, y : Int16) : Int16 { x ^ y };

  public func bitshiftLeft(x : Int16, y : Int16) : Int16 { x << y };

  public func bitshiftRight(x : Int16, y : Int16) : Int16 { x >> y };

  public func bitrotLeft(x : Int16, y : Int16) : Int16 { x <<> y };

  public func bitrotRight(x : Int16, y : Int16) : Int16 { x <>> y };

  public func bittest(x : Int16, p : Nat) : Bool {
    Prim.btstInt16(x, Prim.intToInt16(p))
  };

  public func bitset(x : Int16, p : Nat) : Int16 {
    x | (1 << Prim.intToInt16(p))
  };

  public func bitclear(x : Int16, p : Nat) : Int16 {
    x & ^(1 << Prim.intToInt16(p))
  };

  public func bitflip(x : Int16, p : Nat) : Int16 {
    x ^ (1 << Prim.intToInt16(p))
  };

  public let bitcountNonZero : (x : Int16) -> Int16 = Prim.popcntInt16;

  public let bitcountLeadingZero : (x : Int16) -> Int16 = Prim.clzInt16;

  public let bitcountTrailingZero : (x : Int16) -> Int16 = Prim.ctzInt16;

  public func addWrap(x : Int16, y : Int16) : Int16 { x +% y };

  public func subWrap(x : Int16, y : Int16) : Int16 { x -% y };

  public func mulWrap(x : Int16, y : Int16) : Int16 { x *% y };

  public func powWrap(x : Int16, y : Int16) : Int16 { x **% y };

  public func allValues() : Iter.Iter<Int16> {
    todo()
  };

}
