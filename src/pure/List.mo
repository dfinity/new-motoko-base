/// Immutable singly-linked list

import Array "../Array";
import Iter "../Iter";
import Order "../Order";
import Result "../Result";
import Types "../Types";
import { todo } "../Debug";

module {

  public type List<T> = Types.Pure.List<T>;

  public func empty<T>() : List<T> = null;

  public func isEmpty<T>(list : List<T>) : Bool = todo();

  public func size<T>(list : List<T>) : Nat = todo();

  public func contains<T>(list : List<T>, item : T) : Bool {
    todo()
  };

  public func get<T>(list : List<T>, n : Nat) : ?T {
    todo()
  };

  public func push<T>(list : List<T>, item : T) : List<T> = ?(item, list);

  public func last<T>(list : List<T>) : ?T {
    todo()
  };

  public func pop<T>(list : List<T>) : (?T, List<T>) {
    todo()
  };

  public func reverse<T>(list : List<T>) : List<T> {
    todo()
  };

  public func forEach<T>(list : List<T>, f : T -> ()) {
    todo()
  };

  public func map<T1, T2>(list : List<T1>, f : T1 -> T2) : List<T2> {
    todo()
  };

  public func filter<T>(list : List<T>, f : T -> Bool) : List<T> {
    todo()
  };

  public func filterMap<T, R>(list : List<T>, f : T -> ?R) : List<R> {
    todo()
  };

  public func mapResult<T, R, E>(list : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> {
    todo()
  };

  public func partition<T>(list : List<T>, f : T -> Bool) : (List<T>, List<T>) {
    todo()
  };

  public func concat<T>(list1 : List<T>, list2 : List<T>) : List<T> {
    todo()
  };

  public func join<T>(list : Iter.Iter<List<T>>) : List<T> {
    todo()
  };

  public func flatten<T>(list : List<List<T>>) : List<T> {
    todo()
  };

  public func take<T>(list : List<T>, n : Nat) : List<T> {
    todo()
  };

  public func drop<T>(list : List<T>, n : Nat) : List<T> {
    todo()
  };

  public func foldLeft<T, A>(list : List<T>, base : A, combine : (A, T) -> A) : A {
    todo()
  };

  public func foldRight<T, A>(list : List<T>, base : A, combine : (T, A) -> A) : A {
    todo()
  };

  public func find<T>(list : List<T>, f : T -> Bool) : ?T {
    todo()
  };

  public func all<T>(list : List<T>, f : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(list : List<T>, f : T -> Bool) : Bool {
    todo()
  };

  public func merge<T>(list1 : List<T>, list2 : List<T>, lessThanOrEqual : (T, T) -> Bool) : List<T> {
    todo()
  };

  public func compare<T>(list1 : List<T>, list2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  public func tabulate<T>(n : Nat, f : Nat -> T) : List<T> {
    todo()
  };

  public func singleton<T>(item : T) : List<T> = ?(item, null);

  public func repeat<T>(item : T, n : Nat) : List<T> {
    todo()
  };

  public func zip<T, U>(list1 : List<T>, list2 : List<U>) : List<(T, U)> = zipWith<T, U, (T, U)>(list1, list2, func(x, y) { (x, y) });

  public func zipWith<T, U, V>(list1 : List<T>, list2 : List<U>, f : (T, U) -> V) : List<V> {
    todo()
  };

  public func split<T>(list : List<T>, n : Nat) : (List<T>, List<T>) {
    todo()
  };

  public func chunks<T>(list : List<T>, n : Nat) : List<List<T>> {
    todo()
  };

  public func values<T>(list : List<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromArray<T>(array : [T]) : List<T> {
    todo()
  };

  public func fromVarArray<T>(array : [var T]) : List<T> = fromArray<T>(Array.fromVarArray<T>(array));

  public func toArray<T>(list : List<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(list : List<T>) : [var T] = Array.toVarArray<T>(toArray<T>(list));

  public func fromIter<T>(iter : Iter.Iter<T>) : List<T> = todo();

  public func toText<T>(list : List<T>, f : T -> Text) : Text {
    var text = "[";
    var first = false;
    forEach(
      list,
      func(item : T) {
        if first {
          text #= ", "
        } else {
          first := true
        };
        text #= f(item)
      }
    );
    text # "]"
  };

}
