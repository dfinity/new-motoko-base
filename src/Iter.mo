/// Utilities for `Iter` (iterator) values

import Type "IterType";
import Order "Order";
import { todo } "Debug";

module {

  public type Iter<T> = Type.Iter<T>;

  public func empty<T>() : Iter<T> = { next = func() { null } };

  public class range(fromInclusive : Int, toExclusive : Int) {
    todo()
  };

  public class rangeRev(fromInclusive : Int, toExclusive : Int) {
    todo()
  };

  public func forEach<T>(iter : Iter<T>, f : (T, Nat) -> ()) {
    todo()
  };

  public func size<T>(iter : Iter<T>) : Nat {
    todo()
  };

  public func map<T1, T2>(iter : Iter<T1>, f : T1 -> T2) : Iter<T2> {
    todo()
  };

  public func filter<T>(iter : Iter<T>, f : T -> Bool) : Iter<T> {
    todo()
  };

  public func filterMap<T1, T2>(iter : Iter<T1>, f : T1 -> ?T2) : Iter<T2> {
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

  public func fromArray<T>(array : [T]) : Iter<T> {
    todo()
  };

  public func fromVarArray<T>(array : [var T]) : Iter<T> {
    todo()
  };

  public func toArray<T>(iter : Iter<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(iter : Iter<T>) : [var T] {
    todo()
  };

  public func sort<T>(iter : Iter<T>, compare : (T, T) -> Order.Order) : Iter<T> {
    todo()
  };

}
