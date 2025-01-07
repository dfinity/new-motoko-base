/// 8-bit signed integers

import Int "Int";
import { todo } "Debug";
import Iter "Iter";
import Prim "mo:⛔";

module {

  public type Int8 = Prim.Types.Int8;

  public let minimumValue = -128 : Int8;

  public let maximumValue = 127 : Int8;

  public let toInt : Int8 -> Int = Prim.int8ToInt;

  public let fromInt : Int -> Int8 = Prim.intToInt8;

  public let fromIntWrap : Int -> Int8 = Prim.intToInt8Wrap;

  public let fromInt16 : Int16 -> Int8 = Prim.int16ToInt8;

  public let toInt16 : Int8 -> Int16 = Prim.int8ToInt16;

  public let fromNat8 : Nat8 -> Int8 = Prim.nat8ToInt8;

  public let toNat8 : Int8 -> Nat8 = Prim.int8ToNat8;

  public func toText(x : Int8) : Text {
    Int.toText(toInt(x))
  };

  public func abs(x : Int8) : Int8 {
    fromInt(Int.abs(toInt(x)))
  };

  public func min(x : Int8, y : Int8) : Int8 {
    if (x < y) { x } else { y }
  };

  public func max(x : Int8, y : Int8) : Int8 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Int8, y : Int8) : Bool { x == y };

  public func notEqual(x : Int8, y : Int8) : Bool { x != y };

  public func less(x : Int8, y : Int8) : Bool { x < y };

  public func lessOrEqual(x : Int8, y : Int8) : Bool { x <= y };

  public func greater(x : Int8, y : Int8) : Bool { x > y };

  public func greaterOrEqual(x : Int8, y : Int8) : Bool { x >= y };

  public func compare(x : Int8, y : Int8) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func neg(x : Int8) : Int8 { -x };

  public func add(x : Int8, y : Int8) : Int8 { x + y };

  public func sub(x : Int8, y : Int8) : Int8 { x - y };

  public func mul(x : Int8, y : Int8) : Int8 { x * y };

  public func div(x : Int8, y : Int8) : Int8 { x / y };

  public func rem(x : Int8, y : Int8) : Int8 { x % y };

  public func pow(x : Int8, y : Int8) : Int8 { x ** y };

  public func bitnot(x : Int8) : Int8 { ^x };

  public func bitand(x : Int8, y : Int8) : Int8 { x & y };

  public func bitor(x : Int8, y : Int8) : Int8 { x | y };

  public func bitxor(x : Int8, y : Int8) : Int8 { x ^ y };

  public func bitshiftLeft(x : Int8, y : Int8) : Int8 { x << y };

  public func bitshiftRight(x : Int8, y : Int8) : Int8 { x >> y };

  public func bitrotLeft(x : Int8, y : Int8) : Int8 { x <<> y };

  public func bitrotRight(x : Int8, y : Int8) : Int8 { x <>> y };

  public func bittest(x : Int8, p : Nat) : Bool {
    Prim.btstInt8(x, Prim.intToInt8(p))
  };

  public func bitset(x : Int8, p : Nat) : Int8 {
    x | (1 << Prim.intToInt8(p))
  };

  public func bitclear(x : Int8, p : Nat) : Int8 {
    x & ^(1 << Prim.intToInt8(p))
  };

  public func bitflip(x : Int8, p : Nat) : Int8 {
    x ^ (1 << Prim.intToInt8(p))
  };

  public let bitcountNonZero : (x : Int8) -> Int8 = Prim.popcntInt8;

  public let bitcountLeadingZero : (x : Int8) -> Int8 = Prim.clzInt8;

  public let bitcountTrailingZero : (x : Int8) -> Int8 = Prim.ctzInt8;

  public func addWrap(x : Int8, y : Int8) : Int8 { x +% y };

  public func subWrap(x : Int8, y : Int8) : Int8 { x -% y };

  public func mulWrap(x : Int8, y : Int8) : Int8 { x *% y };

  public func powWrap(x : Int8, y : Int8) : Int8 { x **% y };

  public class range(fromInclusive : Int8, toExclusive : Int8) {
    todo()
  };

  public class rangeInclusive(from : Int8, to : Int8) {
    todo()
  };

  public func allValues() : Iter.Iter<Int8> {
    todo()
  }

}
