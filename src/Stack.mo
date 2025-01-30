/// Mutable stack data structure.

import Immutable "immutable/Stack";
import IterType "type/Iter";
import Order "Order";
import { todo } "Debug";

module {
  type StackNode<T> = {
    value : T;
    next : ?StackNode<T>
  };

  public type Stack<T> = {
    var top : ?StackNode<T>;
    var size : Nat
  };

  public func freeze<T>(stack : Stack<T>) : Immutable.Stack<T> {
    todo()
  };

  public func thaw<T>(stack : Immutable.Stack<T>) : Stack<T> {
    todo()
  };

  public func empty<T>() : Stack<T> {
    {
      var top = null;
      var size = 0
    }
  };

  public func tabulate<T>(size : Nat, generator : Nat -> T) : Stack<T> {
    todo()
  };

  public func clear<T>(stack : Stack<T>) {
    todo();
  };

  public func clone<T>(stack : Stack<T>) : Stack<T> { todo() };

  public func isEmpty<T>(stack : Stack<T>) : Bool {
    todo()
  };

  public func size<T>(stack : Stack<T>) : Nat {
    stack.size
  };

  public func contains<T>(stack : Stack<T>, item : T) : Bool {
    todo()
  };

  public func push<T>(stack : Stack<T>, value : T) {
    let node = {
      value;
      next = stack.top
    };
    stack.top := ?node;
    stack.size += 1
  };

  public func peek<T>(stack : Stack<T>) : ?T {
    todo()
  };

  public func pop<T>(stack : Stack<T>) : ?T {
    switch (stack.top) {
      case null null;
      case (?node) {
        stack.top := node.next;
        stack.size -= 1;
        ?node.value
      }
    }
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

  // public func mapResult<T, R, E>(stack : Stack<T>, f : T -> Result.Result<R, E>) : Result.Result<Stack<R>, E> {
  //   todo()
  // };

  public func partition<T>(stack : Stack<T>, f : T -> Bool) : (Stack<T>, Stack<T>) {
    todo()
  };

  public func concat<T>(stack1 : Stack<T>, stack2 : Stack<T>) : Stack<T> {
    todo()
  };

  public func join<T>(stack : IterType.Iter<Stack<T>>) : Stack<T> {
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

  public func tabulate<T>(n : Nat, f : Nat -> T) : Stack<T> {
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

  public func split<T>(stack : Stack<T>, n : Nat) : (Stack<T>, Stack<T>) {
    todo()
  };

  public func chunks<T>(stack : Stack<T>, n : Nat) : Stack<Stack<T>> {
    todo()
  };

  public func values<T>(stack : Stack<T>) : IterType.Iter<T> {
    todo()
  };

  public func fromIter<T>(iter : IterType.Iter<T>) : Stack<T> {
    todo()
  };

  public func toText<T>(stack : Stack<T>, f : T -> Text) : Text {
    todo()
  }
}
