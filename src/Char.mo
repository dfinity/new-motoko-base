/// Characters
import Prim "mo:⛔";
module {

  public type Char = Prim.Types.Char;

  public let toNat32 : (c : Char) -> Nat32 = Prim.charToNat32;

  public let fromNat32 : (w : Nat32) -> Char = Prim.nat32ToChar;

  public let toText : (c : Char) -> Text = Prim.charToText;

  private let _toUpper : (c : Char) -> Char = Prim.charToUpper;

  private let _toLower : (c : Char) -> Char = Prim.charToLower;

  public func isDigit(c : Char) : Bool {
    Prim.charToNat32(c) -% Prim.charToNat32('0') <= (9 : Nat32)
  };

  public let isWhitespace : (c : Char) -> Bool = Prim.charIsWhitespace;

  public let isLowercase : (c : Char) -> Bool = Prim.charIsLowercase;

  public let isUppercase : (c : Char) -> Bool = Prim.charIsUppercase;

  public let isAlphabetic : (c : Char) -> Bool = Prim.charIsAlphabetic;

  public func equal(x : Char, y : Char) : Bool { x == y };

  public func notEqual(x : Char, y : Char) : Bool { x != y };

  public func less(x : Char, y : Char) : Bool { x < y };

  public func lessOrEqual(x : Char, y : Char) : Bool { x <= y };

  public func greater(x : Char, y : Char) : Bool { x > y };

  public func greaterOrEqual(x : Char, y : Char) : Bool { x >= y };

  public func compare(x : Char, y : Char) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

}
