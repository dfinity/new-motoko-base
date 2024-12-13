/// Original: `OrderedSet.mo`

import Pure "pure/Stack";
import Result "Result";
import Order "Order";
import Iter "Iter";
import { nyi = todo } "Debug";

module {

  public type Stack<T> = { var pure : Pure.Stack<T> };

  public func toPure<T>(stack : Stack<T>) : Pure.Stack<T> = stack.pure;

  public func fromPure<T>(stack : Pure.Stack<T>) : Stack<T> = {
    var pure = stack
  };

  public func new<T>() : Stack<T> = { var pure = Pure.new() };

  public func clone<T>(stack : Stack<T>) : Stack<T> = { var pure = stack.pure };

  public func isEmpty(stack : Stack<Any>) : Bool {
    todo()
  };

  public func size(stack : Stack<Any>) : Nat {
    todo()
  };

  public func contains<T>(stack : Stack<T>, item : T) : Bool {
    todo()
  };

  public func push<T>(stack : Stack<T>, item : T) : () = todo();

  public func last<T>(stack : Stack<T>) : ?T {
    todo()
  };

  public func pop<T>(stack : Stack<T>) : ?T {
    todo()
  };

  public func get<T>(stack : Stack<T>, n : Nat) : ?T {
    todo()
  };

  public func reverse<T>(stack : Stack<T>) : () {
    todo()
  };

  public func forEach<T>(stack : Stack<T>, f : T -> ()) {
    todo()
  };

  public func map<T1, T2>(stack : Stack<T1>, f : T1 -> T2) : Stack<T2> {
    todo()
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

  public func flatten<T>(stack : Stack<Stack<T>>) : Stack<T> {
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

  public func equal<T>(stack1 : Stack<T>, stack2 : Stack<T>) : Bool {
    todo()
  };

  public func generate<T>(n : Nat, f : Nat -> T) : Stack<T> {
    todo()
  };

  public func singleton<T>(item : T) : Stack<T> {
    todo()
  };

  public func repeat<T>(item : T, n : Nat) : Stack<T> {
    todo()
  };

  public func zip<T, U>(stack1 : Stack<T>, stack2 : Stack<U>) : Stack<(T, U)> = zipWith<T, U, (T, U)>(stack1, stack2, func(x, y) { (x, y) });

  public func zipWith<T, U, V>(stack1 : Stack<T>, stack2 : Stack<U>, f : (T, U) -> V) : Stack<V> {
    todo()
  };

  public func split<T>(n : Nat, stack : Stack<T>) : (Stack<T>, Stack<T>) {
    todo()
  };

  public func chunks<T>(n : Nat, stack : Stack<T>) : Stack<Stack<T>> {
    todo()
  };

  public func vals<T>(stack : Stack<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromIter<T>(iter : Iter.Iter<T>) : Stack<T> {
    todo()
  };

  public func toIter<T>(stack : Stack<T>) : Iter.Iter<T> {
    todo()
  };

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
  }
}
