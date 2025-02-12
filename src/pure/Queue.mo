/// Double-ended queue of a generic element type `T`.
///
/// The interface is purely functional, not imperative, and queues are immutable values.
/// In particular, Queue operations such as push and pop do not update their input queue but, instead, return the
/// value of the modified Queue, alongside any other data.
/// The input queue is left unchanged.
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

import Iter "../Iter";
import Order "../Order";
import Types "../Types";
import { todo } "../Debug";

module {
  /// Double-ended queue data type.
  public type Queue<T> = Types.Pure.Queue<T>;

  /// Create a new empty queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  ///
  /// Queue.empty<Nat>()
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> {
    todo()
  };

  /// Determine whether a queue is empty.
  /// Returns true if `queue` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  ///
  /// let queue = Queue.empty<Nat>();
  /// Queue.isEmpty(queue) // => true
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty<T>(queue : Queue<T>) : Bool {
    todo()
  };

  public func singleton<T>(item : T) : Queue<T> {
    todo()
  };

  public func size<T>(queue : Queue<T>) : Nat {
    todo()
  };

  public func contains<T>(queue : Queue<T>, item : T) : Bool {
    todo()
  };

  /// Inspect the optional element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the front element of `queue`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  ///
  /// let queue = Queue.pushFront(Queue.pushFront(Queue.empty<Nat>(), 2), 1);
  /// Queue.peekFront(queue) // => ?1
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  /// Inspect the optional element on the back end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the back element of `queue`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  ///
  /// let queue = Queue.pushBack(Queue.pushBack(Queue.empty<Nat>(), 1), 2);
  /// Queue.peekBack(queue) // => ?2
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  /// Insert a new element on the front end of a queue.
  /// Returns the new queue with `element` in the front followed by the elements of `queue`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  ///
  /// Queue.pushFront(Queue.pushFront(Queue.empty<Nat>(), 2), 1) // queue with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushFront<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  /// Insert a new element on the back end of a queue.
  /// Returns the new queue with all the elements of `queue`, followed by `element` on the back.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  ///
  /// Queue.pushBack(Queue.pushBack(Queue.empty<Nat>(), 1), 2) // queue with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushBack<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  /// Remove the element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, it returns a pair of
  /// the first element and a new queue that contains all the remaining elements of `queue`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  /// import Debug "mo:base/Debug";
  /// let initial = Queue.pushFront(Queue.pushFront(Queue.empty<Nat>(), 2), 1);
  /// // initial queue with elements [1, 2]
  /// let reduced = Queue.popFront(initial);
  /// switch reduced {
  ///   case null {
  ///     Debug.trap "Empty queue impossible"
  ///   };
  ///   case (?result) {
  ///     let removedElement = result.0; // 1
  ///     let reducedQueue = result.1; // queue with element [2].
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popFront<T>(queue : Queue<T>) : ?(T, Queue<T>) {
    todo()
  };

  /// Remove the element on the back end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, it returns a pair of
  /// a new queue that contains the remaining elements of `queue`
  /// and, as the second pair item, the removed back element.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  /// import Debug "mo:base/Debug";
  ///
  /// let initial = Queue.pushBack(Queue.pushBack(Queue.empty<Nat>(), 1), 2);
  /// // initial queue with elements [1, 2]
  /// let reduced = Queue.popBack(initial);
  /// switch reduced {
  ///   case null {
  ///     Debug.trap "Empty queue impossible"
  ///   };
  ///   case (?result) {
  ///     let reducedQueue = result.0; // queue with element [1].
  ///     let removedElement = result.1; // 2
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popBack<T>(queue : Queue<T>) : ?(Queue<T>, T) {
    todo()
  };

  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    todo()
  };

  public func values<T>(queue : Queue<T>) : Iter.Iter<T> {
    todo()
  };

  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>) : Bool {
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

  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    todo()
  };

  public func compare<T>(queue1 : Queue<T>, queue2 : Queue<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

}
