/// Utility functions on 8-bit unsigned integers

import Nat "Nat";
import Prim "mo:⛔";

module {

  public type Nat8 = Prim.Types.Nat8;

  public let maximumValue = 255 : Nat8;

  public let toNat : Nat8 -> Nat = Prim.nat8ToNat;

  public let fromNat : Nat -> Nat8 = Prim.natToNat8;

  public let fromNat16 : Nat16 -> Nat8 = Prim.nat16ToNat8;

  public let toNat16 : Nat8 -> Nat16 = Prim.nat8ToNat16;

  public let fromIntWrap : Int -> Nat8 = Prim.intToNat8Wrap;

  public func toText(x : Nat8) : Text {
    Nat.toText(toNat(x))
  };

  public func min(x : Nat8, y : Nat8) : Nat8 {
    if (x < y) { x } else { y }
  };

  public func max(x : Nat8, y : Nat8) : Nat8 {
    if (x < y) { y } else { x }
  };

  public func equal(x : Nat8, y : Nat8) : Bool { x == y };

  public func notEqual(x : Nat8, y : Nat8) : Bool { x != y };

  public func less(x : Nat8, y : Nat8) : Bool { x < y };

  public func lessOrEqual(x : Nat8, y : Nat8) : Bool { x <= y };

  public func greater(x : Nat8, y : Nat8) : Bool { x > y };

  public func greaterOrEqual(x : Nat8, y : Nat8) : Bool { x >= y };

  public func compare(x : Nat8, y : Nat8) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  public func add(x : Nat8, y : Nat8) : Nat8 { x + y };

  public func sub(x : Nat8, y : Nat8) : Nat8 { x - y };

  public func mul(x : Nat8, y : Nat8) : Nat8 { x * y };

  public func div(x : Nat8, y : Nat8) : Nat8 { x / y };

  public func rem(x : Nat8, y : Nat8) : Nat8 { x % y };

  public func pow(x : Nat8, y : Nat8) : Nat8 { x ** y };

  public func bitnot(x : Nat8) : Nat8 { ^x };

  public func bitand(x : Nat8, y : Nat8) : Nat8 { x & y };

  public func bitor(x : Nat8, y : Nat8) : Nat8 { x | y };

  public func bitxor(x : Nat8, y : Nat8) : Nat8 { x ^ y };

  public func bitshiftLeft(x : Nat8, y : Nat8) : Nat8 { x << y };

  public func bitshiftRight(x : Nat8, y : Nat8) : Nat8 { x >> y };

  public func bitrotLeft(x : Nat8, y : Nat8) : Nat8 { x <<> y };

  public func bitrotRight(x : Nat8, y : Nat8) : Nat8 { x <>> y };

  public func bittest(x : Nat8, p : Nat) : Bool {
    Prim.btstNat8(x, Prim.natToNat8(p))
  };

  public func bitset(x : Nat8, p : Nat) : Nat8 {
    x | (1 << Prim.natToNat8(p))
  };

  public func bitclear(x : Nat8, p : Nat) : Nat8 {
    x & ^(1 << Prim.natToNat8(p))
  };

  public func bitflip(x : Nat8, p : Nat) : Nat8 {
    x ^ (1 << Prim.natToNat8(p))
  };

  public let bitcountNonZero : (x : Nat8) -> Nat8 = Prim.popcntNat8;

  public let bitcountLeadingZero : (x : Nat8) -> Nat8 = Prim.clzNat8;

  public let bitcountTrailingZero : (x : Nat8) -> Nat8 = Prim.ctzNat8;

  public func addWrap(x : Nat8, y : Nat8) : Nat8 { x +% y };

  public func subWrap(x : Nat8, y : Nat8) : Nat8 { x -% y };

  public func mulWrap(x : Nat8, y : Nat8) : Nat8 { x *% y };

  public func powWrap(x : Nat8, y : Nat8) : Nat8 { x **% y };

}