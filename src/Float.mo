/// Double precision (64-bit) floating-point numbers in IEEE 754 representation

import Prim "mo:⛔";
import Int "Int";
import { todo } "Debug";

module {

  public type Float = Prim.Types.Float;

  public let pi : Float = 3.14159265358979323846; // taken from musl math.h

  public let e : Float = 2.7182818284590452354; // taken from musl math.h

  public func isNaN(number : Float) : Bool {
    number != number
  };

  public let abs : (x : Float) -> Float = Prim.floatAbs;

  public let sqrt : (x : Float) -> Float = Prim.floatSqrt;

  public let ceil : (x : Float) -> Float = Prim.floatCeil;

  public let floor : (x : Float) -> Float = Prim.floatFloor;

  public let trunc : (x : Float) -> Float = Prim.floatTrunc;

  public let nearest : (x : Float) -> Float = Prim.floatNearest;

  public let copySign : (x : Float, y : Float) -> Float = Prim.floatCopySign;

  public let min : (x : Float, y : Float) -> Float = Prim.floatMin;

  public let max : (x : Float, y : Float) -> Float = Prim.floatMax;

  public let sin : (x : Float) -> Float = Prim.sin;

  public let cos : (x : Float) -> Float = Prim.cos;

  public let tan : (x : Float) -> Float = Prim.tan;

  public let arcsin : (x : Float) -> Float = Prim.arcsin;

  public let arccos : (x : Float) -> Float = Prim.arccos;

  public let arctan : (x : Float) -> Float = Prim.arctan;

  public let arctan2 : (y : Float, x : Float) -> Float = Prim.arctan2;

  public let exp : (x : Float) -> Float = Prim.exp;

  public let log : (x : Float) -> Float = Prim.log;

  public func format(fmt : { #fix : Nat8; #exp : Nat8; #gen : Nat8; #exact }, x : Float) : Text = switch fmt {
    case (#fix(prec)) { Prim.floatToFormattedText(x, prec, 0) };
    case (#exp(prec)) { Prim.floatToFormattedText(x, prec, 1) };
    case (#gen(prec)) { Prim.floatToFormattedText(x, prec, 2) };
    case (#exact) { Prim.floatToFormattedText(x, 17, 2) }
  };

  public let toText : Float -> Text = Prim.floatToText;

  public let toInt64 : Float -> Int64 = Prim.floatToInt64;

  public let fromInt64 : Int64 -> Float = Prim.int64ToFloat;

  public let toInt : Float -> Int = Prim.floatToInt;

  public let fromInt : Int -> Float = Prim.intToFloat;

  public func equal(x : Float, y : Float) : Bool { x == y };

  public func notEqual(x : Float, y : Float) : Bool { x != y };

  public func equalWithin(x : Float, y : Float, epsilon : Float) : Bool {
    if (not (epsilon >= 0.0)) {
      // also considers NaN, not identical to `epsilon < 0.0`
      Prim.trap("epsilon must be greater or equal 0.0")
    };
    x == y or abs(x - y) <= epsilon // `x == y` to also consider infinity equal
  };

  public func notEqualWithin(x : Float, y : Float, epsilon : Float) : Bool {
    not equalWithin(x, y, epsilon)
  };

  public func less(x : Float, y : Float) : Bool { x < y };

  public func lessOrEqual(x : Float, y : Float) : Bool { x <= y };

  public func greater(x : Float, y : Float) : Bool { x > y };

  public func greaterOrEqual(x : Float, y : Float) : Bool { x >= y };

  public func compare(x : Float, y : Float) : { #less; #equal; #greater } {
    todo()
  };

  public func neg(x : Float) : Float { -x };

  public func add(x : Float, y : Float) : Float { x + y };

  public func sub(x : Float, y : Float) : Float { x - y };

  public func mul(x : Float, y : Float) : Float { x * y };

  public func div(x : Float, y : Float) : Float { x / y };

  public func rem(x : Float, y : Float) : Float { x % y };

  public func pow(x : Float, y : Float) : Float { x ** y };

}
