/// 16-bit unsigned integers

import Nat "Nat";
import Iter "IterType";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Nat16 = Prim.Types.Nat16;

  public let maximumValue = 65535 : Nat16;

  public let toNat : Nat16 -> Nat = Prim.nat16ToNat;

  public let fromNat : Nat -> Nat16 = Prim.natToNat16;

  public func fromNat8(x : Nat8) : Nat16 {
    Prim.nat8ToNat16(x)
  };

  public func toNat8(x : Nat16) : Nat8 {
    Prim.nat16ToNat8(x)
  };

  public func fromNat32(x : Nat32) : Nat16 {
    Prim.nat32ToNat16(x)
  };

  public func toNat32(x : Nat16) : Nat32 {
    Prim.nat16ToNat32(x)
  };

  public let fromIntWrap : Int -> Nat16 = Prim.intToNat16Wrap;

  public func toText(x : Nat16) : Text {
    Nat.toText(toNat(x))
  };

  public func min(x : Nat16, y : Nat16) : Nat16 {
    if (x < y) { x } else { y }
  };

  public func max(x : Nat16, y : Nat16) : Nat16 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Nat16, y : Nat16) : Bool { x == y };

  public func notEqual(x : Nat16, y : Nat16) : Bool { x != y };

  public func less(x : Nat16, y : Nat16) : Bool { x < y };

  public func lessOrEqual(x : Nat16, y : Nat16) : Bool { x <= y };

  public func greater(x : Nat16, y : Nat16) : Bool { x > y };

  public func greaterOrEqual(x : Nat16, y : Nat16) : Bool { x >= y };

  public func compare(x : Nat16, y : Nat16) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func add(x : Nat16, y : Nat16) : Nat16 { x + y };

  public func sub(x : Nat16, y : Nat16) : Nat16 { x - y };

  public func mul(x : Nat16, y : Nat16) : Nat16 { x * y };

  public func div(x : Nat16, y : Nat16) : Nat16 { x / y };

  public func rem(x : Nat16, y : Nat16) : Nat16 { x % y };

  public func pow(x : Nat16, y : Nat16) : Nat16 { x ** y };

  public func bitnot(x : Nat16) : Nat16 { ^x };

  public func bitand(x : Nat16, y : Nat16) : Nat16 { x & y };

  public func bitor(x : Nat16, y : Nat16) : Nat16 { x | y };

  public func bitxor(x : Nat16, y : Nat16) : Nat16 { x ^ y };

  public func bitshiftLeft(x : Nat16, y : Nat16) : Nat16 { x << y };

  public func bitshiftRight(x : Nat16, y : Nat16) : Nat16 { x >> y };

  public func bitrotLeft(x : Nat16, y : Nat16) : Nat16 { x <<> y };

  public func bitrotRight(x : Nat16, y : Nat16) : Nat16 { x <>> y };

  public func bittest(x : Nat16, p : Nat) : Bool {
    Prim.btstNat16(x, Prim.natToNat16(p))
  };

  public func bitset(x : Nat16, p : Nat) : Nat16 {
    x | (1 << Prim.natToNat16(p))
  };

  public func bitclear(x : Nat16, p : Nat) : Nat16 {
    x & ^(1 << Prim.natToNat16(p))
  };

  public func bitflip(x : Nat16, p : Nat) : Nat16 {
    x ^ (1 << Prim.natToNat16(p))
  };

  public let bitcountNonZero : (x : Nat16) -> Nat16 = Prim.popcntNat16;

  public let bitcountLeadingZero : (x : Nat16) -> Nat16 = Prim.clzNat16;

  public let bitcountTrailingZero : (x : Nat16) -> Nat16 = Prim.ctzNat16;

  public func addWrap(x : Nat16, y : Nat16) : Nat16 { x +% y };

  public func subWrap(x : Nat16, y : Nat16) : Nat16 { x -% y };

  public func mulWrap(x : Nat16, y : Nat16) : Nat16 { x *% y };

  public func powWrap(x : Nat16, y : Nat16) : Nat16 { x **% y };

  public func range(fromInclusive : Nat16, toExclusive : Nat16) : Iter.Iter<Nat16> {
    todo()
  };

  public func rangeInclusive(from : Nat16, to : Nat16) : Iter.Iter<Nat16> {
    todo()
  };

  public func allValues() : Iter.Iter<Nat16> {
    todo()
  };

}
