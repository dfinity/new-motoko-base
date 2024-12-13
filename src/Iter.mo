/// Iterators

import Order "Order";
import Stack "pure/Stack";
import { nyi = todo } "Debug";

module {

  public type Iter<T> = { next : () -> ?T };

  public class range(fromInclusive : Int, toExclusive : Int) {
    todo()
  };

  public class rangeRev(fromInclusive : Int, toExclusive : Int) {
    todo()
  };

  public func forEach<T>(xs : Iter<T>, f : (T, Nat) -> ()) {
    todo()
  };

  public func size<T>(xs : Iter<T>) : Nat {
    todo()
  };

  public func map<T1, T2>(xs : Iter<T1>, f : T1 -> T2) : Iter<T2> {
    todo()
  };

  public func filter<T>(xs : Iter<T>, f : T -> Bool) : Iter<T> {
    todo()
  };

  public func filterMap<T1, T2>(xs : Iter<T1>, f : T1 -> ?T2) : Iter<T2> {
    todo()
  };

  public func infinite<T>(x : T) : Iter<T> {
    todo()
  };

  public func singleton<T>(x : T) : Iter<T> {
    todo()
  };

  public func concat<T>(a : Iter<T>, b : Iter<T>) : Iter<T> {
    todo()
  };

  public func concatAll<T>(iters : [Iter<T>]) : Iter<T> {
    todo()
  };

  public func fromArray<T>(xs : [T]) : Iter<T> {
    todo()
  };

  public func fromVarArray<T>(xs : [var T]) : Iter<T> {
    todo()
  };

  public let fromList = List.vals;

  public func toArray<T>(xs : Iter<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(xs : Iter<T>) : [var T] {
    todo()
  };

  public func toList<T>(xs : Iter<T>) : List.List<T> {
    todo()
  };

  public func sort<T>(xs : Iter<T>, compare : (T, T) -> Order.Order) : Iter<T> {
    todo()
  };

}
