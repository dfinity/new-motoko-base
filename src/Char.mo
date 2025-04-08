/// Utilities for `Char` (character)

import Prim "mo:⛔";
import Iter "Iter";
import Order "Order";

module {

  /// Characters represented as Unicode code points.
  public type Char = Prim.Types.Char;

  /// Convert character `char` to a word containing its Unicode scalar value.
  public let toNat32 : (char : Char) -> Nat32 = Prim.charToNat32;

  /// Convert `w` to a character.
  /// Traps if `w` is not a valid Unicode scalar value.
  /// Value `w` is valid if, and only if, `w < 0xD800 or (0xE000 <= w and w <= 0x10FFFF)`.
  public let fromNat32 : (nat32 : Nat32) -> Char = Prim.nat32ToChar;

  /// Convert character `char` to single character text.
  public let toText : (char : Char) -> Text = Prim.charToText;

  // Not exposed pending multi-char implementation.
  private let _toUpper : (char : Char) -> Char = Prim.charToUpper;

  // Not exposed pending multi-char implementation.
  private let _toLower : (char : Char) -> Char = Prim.charToLower;

  /// Returns `true` when `char` is a decimal digit between `0` and `9`, otherwise `false`.
  public func isDigit(char : Char) : Bool {
    Prim.charToNat32(char) -% Prim.charToNat32('0') <= (9 : Nat32)
  };

  /// Returns whether `char` is a whitespace character.
  public let isWhitespace : (char : Char) -> Bool = Prim.charIsWhitespace;

  /// Returns whether `char` is a lowercase character.
  public let isLower : (char : Char) -> Bool = Prim.charIsLowercase;

  /// Returns whether `char` is an uppercase character.
  public let isUpper : (char : Char) -> Bool = Prim.charIsUppercase;

  /// Returns whether `char` is an alphanumeric character.
  public let isAlphabetic : (char : Char) -> Bool = Prim.charIsAlphabetic;

  /// Returns `a == b`.
  public func equal(a : Char, b : Char) : Bool { a == b };

  /// Returns `a != b`.
  public func notEqual(a : Char, b : Char) : Bool { a != b };

  /// Returns `a < b`.
  public func less(a : Char, b : Char) : Bool { a < b };

  /// Returns `a <= b`.
  public func lessOrEqual(a : Char, b : Char) : Bool { a <= b };

  /// Returns `a > b`.
  public func greater(a : Char, b : Char) : Bool { a > b };

  /// Returns `a >= b`.
  public func greaterOrEqual(a : Char, b : Char) : Bool { a >= b };

  /// Returns the order of `a` and `b`.
  public func compare(a : Char, b : Char) : Order.Order {
    if (a < b) { #less } else if (a == b) { #equal } else { #greater }
  };

}
