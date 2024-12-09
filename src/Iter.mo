/// Iterators

import { nyi = todo } "Debug";
module {
  public type Iter<T> = { next : () -> ?T };

  public class range(x : Nat, y : Int) {
    todo()
  };

  public class revRange(x : Int, y : Int) {
    todo()
  };

  public func iterate<A>(xs : Iter<A>, f : (A, Nat) -> ()) {
    todo()
  };

  public func size<A>(xs : Iter<A>) : Nat {
    todo()
  };

  public func map<A, B>(xs : Iter<A>, f : A -> B) : Iter<B> = object {
    todo()
  };

  public func filter<A>(xs : Iter<A>, f : A -> Bool) : Iter<A> = object {
    todo()
  };

  public func infinite<A>(x : A) : Iter<A> = object {
    todo()
  };

  public func concat<A>(a : Iter<A>, b : Iter<A>) : Iter<A> {
    todo()
  };

  public func fromArray<A>(xs : [A]) : Iter<A> {
    todo()
  };

  public func fromArrayMut<A>(xs : [var A]) : Iter<A> {
    todo()
  };

  // public let fromList = List.toIter;

  public func toArray<A>(xs : Iter<A>) : [A] {
    todo()
  };

  public func toArrayMut<A>(xs : Iter<A>) : [var A] {
    todo()
  };

  // public func toList<A>(xs : Iter<A>) : List.List<A> {
  //   todo()
  // };

  public func sort<A>(xs : Iter<A>, compare : (A, A) -> Order.Order) : Iter<A> {
    todo()
  };

}
