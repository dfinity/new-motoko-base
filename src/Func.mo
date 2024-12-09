/// Functions on functions, creating functions from simpler inputs

module {
  public func compose<A, B, C>(f : B -> C, g : A -> B) : A -> C {
    func(x : A) : C {
      f(g(x))
    }
  };

  public func identity<A>(x : A) : A = x;

  public func const<A, B>(x : A) : B -> A = func _ = x
}
