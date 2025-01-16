/// Double-ended queue of a generic element type `T`.
///
/// The interface is purely functional, not imperative, and queues are immutable values.
/// In particular, Queue operations such as push and pop do not update their input deque but, instead, return the
/// value of the modified Queue, alongside any other data.
/// The input deque is left unchanged.
///
/// Examples of use-cases:
/// Queue (FIFO) by using `pushBack()` and `popFront()`.
/// Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// A Queue is internally implemented as two lists, a head access list and a (reversed) tail access list,
/// that are dynamically size-balanced by splitting.
///
/// Construction: Create a new deque with the `empty<T>()` function.
///
/// Note on the costs of push and pop functions:
/// * Runtime: `O(1)` amortized costs, `O(n)` worst case cost per single call.
/// * Space: `O(1)` amortized costs, `O(n)` worst case cost per single call.
///
/// `n` denotes the number of elements stored in the deque.

import Iter "../Iter";
import Stack "Stack";
import Order "../Order";
import { todo } "../Debug";

module {
  /// Double-ended queue data type.
  public type Queue<T> = (Stack.Stack<T>, Stack.Stack<T>);

  /// Create a new empty deque.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.empty<Nat>()
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> {
    todo()
  };

  /// Determine whether a deque is empty.
  /// Returns true if `deque` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.empty<Nat>();
  /// Deque.isEmpty(deque) // => true
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty(queue : Queue<Any>) : Bool {
    todo()
  };

  public func singleton<T>(item : T) : Queue<T> {
    todo()
  };

  public func size(queue : Queue<Any>) : Nat {
    todo()
  };

  public func contains<T>(queue : Queue<T>, item : T) : Bool {
    todo()
  };

  /// Inspect the optional element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the front element of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// Deque.peekFront(deque) // => ?1
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  /// Inspect the optional element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the back element of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// Deque.peekBack(deque) // => ?2
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  /// Insert a new element on the front end of a deque.
  /// Returns the new deque with `element` in the front followed by the elements of `deque`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1) // deque with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func pushFront<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  /// Insert a new element on the back end of a deque.
  /// Returns the new deque with all the elements of `deque`, followed by `element` on the back.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2) // deque with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func pushBack<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  /// Remove the element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of
  /// the first element and a new deque that contains all the remaining elements of `deque`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  /// import Debug "mo:base/Debug";
  /// let initial = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// // initial deque with elements [1, 2]
  /// let reduced = Deque.popFront(initial);
  /// switch reduced {
  ///   case null {
  ///     Debug.trap "Empty queue impossible"
  ///   };
  ///   case (?result) {
  ///     let removedElement = result.0; // 1
  ///     let reducedDeque = result.1; // deque with element [2].
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func popFront<T>(queue : Queue<T>) : ?(T, Queue<T>) {
    todo()
  };

  /// Remove the element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of
  /// a new deque that contains the remaining elements of `deque`
  /// and, as the second pair item, the removed back element.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  /// import Debug "mo:base/Debug";
  ///
  /// let initial = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// // initial deque with elements [1, 2]
  /// let reduced = Deque.popBack(initial);
  /// switch reduced {
  ///   case null {
  ///     Debug.trap "Empty queue impossible"
  ///   };
  ///   case (?result) {
  ///     let reducedDeque = result.0; // deque with element [1].
  ///     let removedElement = result.1; // 2
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
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
