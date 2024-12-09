/// Typesafe nulls

import Debug "Debug";

module {

  public func get<T>(x : ?T, default : T) : T = switch x {
    case null { default };
    case (?x_) { x_ }
  };

  public func getMapped<A, B>(x : ?A, f : A -> B, default : B) : B = switch x {
    case null { default };
    case (?x_) { f(x_) }
  };

  public func map<A, B>(x : ?A, f : A -> B) : ?B = switch x {
    case null { null };
    case (?x_) { ?f(x_) }
  };

  public func forEach<A>(x : ?A, f : A -> ()) = switch x {
    case null {};
    case (?x_) { f(x_) }
  };

  public func apply<A, B>(x : ?A, f : ?(A -> B)) : ?B {
    switch (f, x) {
      case (?f_, ?x_) { ?f_(x_) };
      case (_, _) { null }
    }
  };

  public func chain<A, B>(x : ?A, f : A -> ?B) : ?B {
    switch (x) {
      case (?x_) { f(x_) };
      case (null) { null }
    }
  };

  public func flatten<A>(x : ??A) : ?A {
    chain<?A, A>(x, func(x_ : ?A) : ?A = x_)
  };

  public func some<A>(x : A) : ?A = ?x;

  public func isSome(x : ?Any) : Bool {
    x != null
  };

  public func isNull(x : ?Any) : Bool {
    x == null
  };

  public func equal<A>(x : ?A, y : ?A, eq : (A, A) -> Bool) : Bool = switch (x, y) {
    case (null, null) { true };
    case (?x_, ?y_) { eq(x_, y_) };
    case (_, _) { false }
  };

  public func assertSome(x : ?Any) = switch x {
    case null { Debug.trap("Option.assertSome()") };
    case _ {}
  };

  public func assertNull(x : ?Any) = switch x {
    case null {};
    case _ { Debug.trap("Option.assertNull()") }
  };

  public func unwrap<T>(x : ?T) : T = switch x {
    case null { Debug.trap("Option.unwrap()") };
    case (?x_) { x_ }
  }
}
