/// Double-ended queue of a generic element type `T`.
///
/// The interface is imperative, not purely functional.
/// In particular, Queue operations such as push and pop update their input queue instead of returning the
/// value of the modified Queue.
///
/// Examples of use-cases:
/// Queue (FIFO) by using `pushBack()` and `popFront()`.
/// Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// A Queue is internally implemented as two lists, a head access list and a (reversed) tail access list,
/// that are dynamically size-balanced by splitting.
///
/// Construction: Create a new queue with the `empty<T>()` function.
///
/// Note on the costs of push and pop functions:
/// * Runtime: `O(1)` amortized costs, `O(n)` worst case cost per single call.
/// * Space: `O(1)` amortized costs, `O(n)` worst case cost per single call.
///
/// `n` denotes the number of elements stored in the queue.

import Iter "Iter";
import Immutable "immutable/Queue";
import Order "Order";
import Types "Types";
import { todo } "Debug";

module {

  public type Queue<T> = Types.Queue<T>;

  public func freeze<T>(queue : Queue<T>) : Immutable.Queue<T> = queue.immutable;

  public func thaw<T>(queue : Immutable.Queue<T>) : Queue<T> {
    { var immutable = queue }
  };

  public func empty<T>() : Queue<T> = { var immutable = Immutable.empty() };

  public func singleton<T>(item : T) : Queue<T> {
    { var immutable = Immutable.singleton(item) }
  };

  public func clear<T>(queue : Queue<T>) {
    queue.immutable := Immutable.empty();
  };

  public func clone<T>(queue : Queue<T>) : Queue<T> = { var immutable = queue.immutable };

  public func isEmpty<T>(queue : Queue<T>) : Bool {
    todo()
  };

  public func size<T>(queue : Queue<T>) : Nat {
    todo()
  };

  public func contains<T>(queue : Queue<T>, item : T) : Bool {
    todo()
  };

  public func peekFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func peekBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func push<T>(queue : Queue<T>, element : T) : () {
    todo()
  };

  public func pop<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func pushFront<T>(queue : Queue<T>, element : T) : () {
    todo()
  };

  public func pushBack<T>(queue : Queue<T>, element : T) : () {
    todo()
  };

  public func popFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func popBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    todo()
  };

  public func values<T>(queue : Queue<T>) : Iter.Iter<T> {
    todo()
  };

  public func all<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func forEach<T>(queue : Queue<T>, f : T -> ()) {
    todo()
  };

  public func map<T1, T2>(queue : Queue<T1>, f : T1 -> T2) : Queue<T2> {
    todo()
  };

  public func filter<T>(queue : Queue<T>, f : T -> Bool) : Queue<T> {
    todo()
  };

  public func filterMap<T, U>(queue : Queue<T>, f : T -> ?U) : Queue<U> {
    todo()
  };

  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>) : Bool {
    todo()
  };

  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    todo()
  };

  public func compare<T>(queue1 : Queue<T>, queue2 : Queue<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

}
