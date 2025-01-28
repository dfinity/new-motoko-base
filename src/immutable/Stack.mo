/// Immutable singly-linked list

import Array "../Array";
import Iter "../Iter";
import Order "../Order";
import Result "../Result";
import { todo } "../Debug";

module {

  public type Stack<T> = ?(Stack<T>, T);

  public func empty<T>() : Stack<T> = null;

  public func isEmpty<T>(stack : Stack<T>) : Bool =
    switch stack { case null true; case _ false };

  public func size<T>(stack : Stack<T>) : Nat =
    switch stack {
      case null 0;
      case (?(t, h)) 1 + size<T> t
    };

  public func contains<T>(stack : Stack<T>, item : T, eq : (T, T) -> Bool) : Bool =
    switch stack {
      case null false;
      case (?(t, h)) eq(h, item) or contains<T>(t, item, eq)
    };

  public func get<T>(stack : Stack<T>, n : Nat) : ?T =
    switch stack {
      case null null;
      case (?(t, h)) if (n == 0) ?h else get(t, /*(with underflow = false)*/ n - 1)
    };

  public func push<T>(stack : Stack<T>, item : T) : Stack<T> = ?(stack, item);

  public func last<T>(stack : Stack<T>) : ?T =
    switch stack {
      case null null;
      case (?(null, h)) ?h;
      case (?(t, _)) last t
    };

  public func pop<T>(stack : Stack<T>) : (?T, Stack<T>) =
    switch stack {
      case null (null, null);
      case (?(t, h)) (?h, t)
    };

  public func reverse<T>(stack : Stack<T>) : Stack<T> {
    todo()
  };

  public func forEach<T>(stack : Stack<T>, f : T -> ()) =
    switch stack {
      case null ();
      case (?(t, h)) { f h; forEach(t, f)}
    };

  public func map<T1, T2>(stack : Stack<T1>, f : T1 -> T2) : Stack<T2> =
    switch stack {
      case null null;
      case (?(t, h)) ?(f h, map(t, f))
    };

  public func filter<T>(stack : Stack<T>, f : T -> Bool) : Stack<T> {
    todo()
  };

  public func filterMap<T, U>(stack : Stack<T>, f : T -> ?U) : Stack<U> {
    todo()
  };

  public func mapResult<T, R, E>(stack : Stack<T>, f : T -> Result.Result<R, E>) : Result.Result<Stack<R>, E> {
    todo()
  };

  public func partition<T>(stack : Stack<T>, f : T -> Bool) : (Stack<T>, Stack<T>) {
    todo()
  };

  public func concat<T>(stack1 : Stack<T>, stack2 : Stack<T>) : Stack<T> {
    todo()
  };

  public func flatten<T>(stack : Iter.Iter<Stack<T>>) : Stack<T> {
    todo()
  };

  public func take<T>(stack : Stack<T>, n : Nat) : Stack<T> {
    todo()
  };

  public func drop<T>(stack : Stack<T>, n : Nat) : Stack<T> {
    todo()
  };

  public func foldLeft<T, A>(stack : Stack<T>, base : A, combine : (A, T) -> A) : A {
    todo()
  };

  public func foldRight<T, A>(stack : Stack<T>, base : A, combine : (T, A) -> A) : A {
    todo()
  };

  public func find<T>(stack : Stack<T>, f : T -> Bool) : ?T {
    todo()
  };

  public func all<T>(stack : Stack<T>, f : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(stack : Stack<T>, f : T -> Bool) : Bool {
    todo()
  };

  public func merge<T>(stack1 : Stack<T>, stack2 : Stack<T>, lessThanOrEqual : (T, T) -> Bool) : Stack<T> {
    todo()
  };

  public func compare<T>(stack1 : Stack<T>, stack2 : Stack<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  public func generate<T>(n : Nat, f : Nat -> T) : Stack<T> {
    todo()
  };

  public func singleton<T>(item : T) : Stack<T> = ?(null, item);

  public func repeat<T>(item : T, n : Nat) : Stack<T> {
    todo()
  };

  public func zip<T, U>(stack1 : Stack<T>, stack2 : Stack<U>) : Stack<(T, U)> = zipWith<T, U, (T, U)>(stack1, stack2, func(x, y) { (x, y) });

  public func zipWith<T, U, V>(stack1 : Stack<T>, stack2 : Stack<U>, f : (T, U) -> V) : Stack<V> {
    todo()
  };

  public func split<T>(stack : Stack<T>, n : Nat) : (Stack<T>, Stack<T>) {
    todo()
  };

  public func chunks<T>(stack : Stack<T>, n : Nat) : Stack<Stack<T>> {
    todo()
  };

  public func values<T>(stack : Stack<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromArray<T>(array : [T]) : Stack<T> {
    todo()
  };

  public func fromVarArray<T>(array : [var T]) : Stack<T> = fromArray<T>(Array.fromVarArray<T>(array));

  public func toArray<T>(stack : Stack<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(stack : Stack<T>) : [var T] = Array.toVarArray<T>(toArray<T>(stack));

  public func fromIter<T>(iter : Iter.Iter<T>) : Stack<T> = todo();

  public func toText<T>(stack : Stack<T>, f : T -> Text) : Text {
    var text = "Stack[";
    var first = false;
    forEach(
      stack,
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
