/// Purely-functional, singly-linked lists.

import Array "Array";
import Iter "../IterType";
import Option "../Option";
import Order "../Order";
import Result "../Result";
import { nyi = todo } "../Debug";

module {
  public type List<T> = ?(T, List<T>);

  public func nil<T>() : List<T> = null;

  public func isNil<T>(l : List<T>) : Bool = todo();

  public func push<T>(x : T, l : List<T>) : List<T> = ?(x, l);

  public func last<T>(l : List<T>) : ?T {
    todo()
  };

  public func pop<T>(l : List<T>) : (?T, List<T>) {
    todo()
  };

  public func size<T>(l : List<T>) : Nat {
    todo()
  };
  public func get<T>(l : List<T>, n : Nat) : ?T {
    todo()
  };

  public func reverse<T>(l : List<T>) : List<T> {
    todo()
  };

  public func forEach<T>(l : List<T>, f : T -> ()) {
    todo()
  };

  public func map<T, U>(l : List<T>, f : T -> U) : List<U> {
    todo()
  };

  public func filter<T>(l : List<T>, f : T -> Bool) : List<T> {
    todo()
  };

  public func partition<T>(l : List<T>, f : T -> Bool) : (List<T>, List<T>) {
    todo()
  };

  public func mapFilter<T, U>(l : List<T>, f : T -> ?U) : List<U> {
    todo()
  };

  public func mapResult<T, R, E>(xs : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> {
    todo()
  };

  func revAppend<T>(l : List<T>, m : List<T>) : List<T> {
    todo()
  };

  public func append<T>(l : List<T>, m : List<T>) : List<T> {
    todo()
  };

  public func flatten<T>(l : List<List<T>>) : List<T> {
    todo()
  };

  public func take<T>(l : List<T>, n : Nat) : List<T> {
    todo()
  };

  public func drop<T>(l : List<T>, n : Nat) : List<T> {
    todo()
  };

  public func foldLeft<T, S>(list : List<T>, base : S, combine : (S, T) -> S) : S {
    todo()
  };

  public func foldRight<T, S>(list : List<T>, base : S, combine : (T, S) -> S) : S {
    todo()
  };

  public func find<T>(l : List<T>, f : T -> Bool) : ?T {
    todo()
  };

  public func some<T>(l : List<T>, f : T -> Bool) : Bool {
    todo()
  };

  public func all<T>(l : List<T>, f : T -> Bool) : Bool {
    todo()
  };

  public func merge<T>(l1 : List<T>, l2 : List<T>, lessThanOrEqual : (T, T) -> Bool) : List<T> {
    todo()
  };

  private func compareAux<T>(l1 : List<T>, l2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  public func compare<T>(l1 : List<T>, l2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  private func equalAux<T>(l1 : List<T>, l2 : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };
  public func equal<T>(l1 : List<T>, l2 : List<T>, equal : (T, T) -> Bool) : Bool {
    equalAux<T>(l1, l2, equal)
  };

  public func tabulate<T>(n : Nat, f : Nat -> T) : List<T> {
    todo()
  };

  public func make<T>(x : T) : List<T> = ?(x, null);

  public func replicate<T>(n : Nat, x : T) : List<T> {
    todo()
  };

  public func zip<T, U>(xs : List<T>, ys : List<U>) : List<(T, U)> = zipWith<T, U, (T, U)>(xs, ys, func(x, y) { (x, y) });

  public func zipWith<T, U, V>(xs : List<T>, ys : List<U>, f : (T, U) -> V) : List<V> {
    todo()
  };

  public func split<T>(n : Nat, xs : List<T>) : (List<T>, List<T>) {
    todo()
  };

  public func chunks<T>(n : Nat, xs : List<T>) : List<List<T>> {
    todo()
  };

  public func fromArray<T>(xs : [T]) : List<T> {
    todo()
  };

  public func fromVarArray<T>(xs : [var T]) : List<T> = fromArray<T>(Array.freeze<T>(xs));

  public func toArray<T>(xs : List<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(xs : List<T>) : [var T] = Array.thaw<T>(toArray<T>(xs));

  public func toIter<T>(xs : List<T>) : Iter.Iter<T> {
    todo()
  };

  public func toText<T>(xs : List<T>, f : T -> Text) : Text {
    var text = "[";
    var first = false;
    forEach(
      xs,
      func(x : T) {
        if first {
          text #= ", "
        } else {
          first := true
        };
        text #= f(x)
      }
    );
    text # "]"
  }
}
