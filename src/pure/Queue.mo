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
///
/// ```motoko name=import
/// import Queue "mo:base/pure/Queue";
/// ```

import Iter "../Iter";
import List "List";
import Order "../Order";
import Types "../Types";

module {
  type List<T> = Types.Pure.List<T>;

  /// Double-ended queue data type.
  public type Queue<T> = Types.Pure.Queue<T>;

  /// Create a new empty queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert Queue.isEmpty(queue);
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> = (null, 0, null);

  /// Determine whether a queue is empty.
  /// Returns true if `queue` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert Queue.isEmpty(queue);
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty<T>(queue : Queue<T>) : Bool = queue.1 == 0;

  /// Create a new queue comprising a single element.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.singleton(25);
  ///   assert Queue.size(queue) == 1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func singleton<T>(item : T) : Queue<T> = (null, 1, ?(item, null));

  /// Determine the number of elements contained in a queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.singleton(42);
  ///   assert Queue.size(queue) == 1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func size<T>(queue : Queue<T>) : Nat {
    debug assert queue.1 == List.size(queue.0) + List.size(queue.2);
    queue.1
  };

  /// Check if a queue contains a specific element.
  /// Returns true if the queue contains an element equal to `item` according to the `equal` function.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   assert Queue.contains(queue, Nat.equal, 2);
  ///   assert not Queue.contains(queue, Nat.equal, 4);
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func contains<T>(queue : Queue<T>, equal : (T, T) -> Bool, item : T) : Bool = List.contains(queue.0, equal, item) or List.contains(queue.2, equal, item);

  /// Inspect the optional element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the front element of `queue`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.pushFront(Queue.pushFront(Queue.empty(), 2), 1);
  ///   assert Queue.peekFront(queue) == ?1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekFront<T>(queue : Queue<T>) : ?T = switch queue {
    case ((?(x, _), _, _) or (_, _, ?(x, null))) ?x;
    case _ { debug assert List.isEmpty(queue.2); null }
  };

  /// Inspect the optional element on the back end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the back element of `queue`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.pushBack(Queue.pushBack(Queue.empty(), 1), 2);
  ///   assert Queue.peekBack(queue) == ?2;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekBack<T>(queue : Queue<T>) : ?T = switch queue {
    case ((_, _, ?(x, _)) or (?(x, null), _, _)) ?x;
    case _ { debug assert List.isEmpty(queue.0); null }
  };

  // helper to split the list evenly
  func takeDrop<T>(list : List<T>, n : Nat) : (List<T>, List<T>) = if (n == 0) (null, list) else switch list {
    case null (null, null);
    case (?(h, t)) {
      let (f, b) = takeDrop(t, n - 1 : Nat);
      (?(h, f), b)
    }
  };

  // helper to rebalance the queue after getting lopsided
  func check<T>(q : Queue<T>) : Queue<T> {
    switch q {
      case (null, n, r) {
        let (a, b) = takeDrop(r, n / 2);
        (List.reverse b, n, a)
      };
      case (f, n, null) {
        let (a, b) = takeDrop(f, n / 2);
        (a, n, List.reverse b)
      };
      case q q
    }
  };

  /// Insert a new element on the front end of a queue.
  /// Returns the new queue with `element` in the front followed by the elements of `queue`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.pushFront(Queue.pushFront(Queue.empty(), 2), 1);
  ///   assert Queue.peekFront(queue) == ?1;
  ///   assert Queue.peekBack(queue) == ?2;
  ///   assert Queue.size(queue) == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushFront<T>(queue : Queue<T>, element : T) : Queue<T> = check(?(element, queue.0), queue.1 + 1, queue.2);

  /// Insert a new element on the back end of a queue.
  /// Returns the new queue with all the elements of `queue`, followed by `element` on the back.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.pushBack(Queue.pushBack(Queue.empty(), 1), 2);
  ///   assert Queue.peekBack(queue) == ?2;
  ///   assert Queue.size(queue) == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushBack<T>(queue : Queue<T>, element : T) : Queue<T> = check(queue.0, queue.1 + 1, ?(element, queue.2));

  /// Remove the element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, it returns a pair of
  /// the first element and a new queue that contains all the remaining elements of `queue`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Runtime "mo:base/Runtime";
  ///
  /// persistent actor {
  ///   let initial = Queue.pushBack(Queue.pushBack(Queue.empty(), 1), 2);
  ///   // initial queue with elements [1, 2]
  ///   switch (Queue.popFront(initial)) {
  ///     case null Runtime.trap "Empty queue impossible";
  ///     case (?(frontElement, remainingQueue)) {
  ///       assert frontElement == 1;
  ///       assert Queue.size(remainingQueue) == 1
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popFront<T>(queue : Queue<T>) : ?(T, Queue<T>) = if (queue.1 == 0) null else switch queue {
    case (?(i, f), n, b) ?(i, (f, n - 1, b));
    case (null, _, ?(i, null)) ?(i, (null, 0, null));
    case _ popFront(check queue)
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
  /// import Queue "mo:base/pure/Queue";
  /// import Runtime "mo:base/Runtime";
  ///
  /// persistent actor {
  ///   let initial = Queue.pushBack(Queue.pushBack(Queue.empty(), 1), 2);
  ///   // initial queue with elements [1, 2]
  ///   let reduced = Queue.popBack(initial);
  ///   switch reduced {
  ///     case null Runtime.trap("Empty queue impossible");
  ///     case (?result) {
  ///       let reducedQueue = result.0;
  ///       let removedElement = result.1;
  ///       assert removedElement == 2;
  ///       assert Queue.size(reducedQueue) == 1;
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popBack<T>(queue : Queue<T>) : ?(Queue<T>, T) = if (queue.1 == 0) null else switch queue {
    case (f, n, ?(i, b)) ?((f, n - 1, b), i);
    case (?(i, null), _, null) ?((null, 0, null), i);
    case _ popBack(check queue)
  };

  /// Turn an iterator into a queue, consuming it.
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2, 3, 4].values());
  ///   assert Queue.size(queue) == 5;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    let list = List.fromIter iter;
    check(list, List.size list, null)
  };

  /// Convert a queue to an iterator of its elements in front-to-back order.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Iter "mo:base/Iter";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   assert Iter.toArray(Queue.values(queue)) == [1, 2, 3];
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func values<T>(queue : Queue<T>) : Iter.Iter<T> = Iter.concat(List.values(queue.0), List.values(List.reverse(queue.2)));

  /// Compare two queues for equality using the provided equality function.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter([1, 2].values());
  ///   let queue2 = Queue.fromIter([1, 2].values());
  ///   let queue3 = Queue.fromIter([1, 3].values());
  ///   assert Queue.equal(queue1, queue2, Nat.equal);
  ///   assert not Queue.equal(queue1, queue3, Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>, equal : (T, T) -> Bool) : Bool {
    if (queue1.1 != queue2.1) {
      return false
    };
    let (iter1, iter2) = (values(queue1), values(queue2));
    loop {
      switch (iter1.next(), iter2.next()) {
        case (null, null) { return true };
        case (?v1, ?v2) {
          if (not equal(v1, v2)) { return false }
        };
        case (_, _) { return false }
      }
    }
  };

  /// Return true if the given predicate `f` is true for all queue
  /// elements.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let allGreaterThanOne = Queue.all<Nat>(queue, func n = n > 1);
  ///   assert not allGreaterThanOne; // false because 1 is not > 1
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func all<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    for (item in values queue) if (not (predicate item)) return false;
    return true
  };

  /// Return true if there exists a queue element for which
  /// the given predicate `f` is true.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let hasGreaterThanOne = Queue.any<Nat>(queue, func n = n > 1);
  ///   assert hasGreaterThanOne; // true because 2 and 3 are > 1
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func any<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    for (item in values queue) if (predicate item) return true;
    return false
  };

  /// Call the given function for its side effect, with each queue element in turn.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   var text = "";
  ///   let queue = Queue.fromIter(["A", "B", "C"].values());
  ///   Queue.forEach<Text>(queue, func n = text #= n);
  ///   assert text == "ABC";
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(queue : Queue<T>, f : T -> ()) = for (item in values queue) f item;

  /// Call the given function `f` on each queue element and collect the results
  /// in a new queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Iter "mo:base/Iter";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2].values());
  ///   let textQueue = Queue.map<Nat, Text>(queue, Nat.toText);
  ///   assert Iter.toArray(Queue.values(textQueue)) == ["0", "1", "2"];
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<T1, T2>(queue : Queue<T1>, f : T1 -> T2) : Queue<T2> {
    let (fr, n, b) = queue;
    (List.map(fr, f), n, List.map(b, f))
  };

  /// Create a new queue with only those elements of the original queue for which
  /// the given function (often called the _predicate_) returns true.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2, 1].values());
  ///   let filtered = Queue.filter<Nat>(queue, func n = n != 1);
  ///   assert Queue.size(filtered) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func filter<T>(queue : Queue<T>, f : T -> Bool) : Queue<T> {
    let (fr, _, b) = queue;
    let front = List.filter(fr, f);
    let back = List.filter(b, f);
    check(front, List.size front + List.size back, back)
  };

  /// Call the given function on each queue element, and collect the non-null results
  /// in a new queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let doubled = Queue.filterMap<Nat, Nat>(
  ///     queue,
  ///     func n = if (n > 1) ?(n * 2) else null
  ///   );
  ///   assert Queue.size(doubled) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func filterMap<T, U>(queue : Queue<T>, f : T -> ?U) : Queue<U> {
    let (fr, _n, b) = queue;
    let front = List.filterMap(fr, f);
    let back = List.filterMap(b, f);
    check(front, List.size front + List.size back, back)
  };

  /// Convert a queue to its text representation using the provided conversion function.
  /// This function is meant to be used for debugging and testing purposes.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   assert Queue.toText(queue, Nat.toText) == "PureQueue[1, 2, 3]";
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    var text = "PureQueue[";
    func add(item : T) {
      if (text.size() > 10) text #= ", ";
      text #= f(item)
    };
    List.forEach(queue.0, add);
    List.forEach(List.reverse(queue.2), add);
    text # "]"
  };

  /// Compare two queues using lexicographic ordering specified by argument function `compareItem`.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/pure/Queue";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter([1, 2].values());
  ///   let queue2 = Queue.fromIter([1, 3].values());
  ///   assert Queue.compare(queue1, queue2, Nat.compare) == #less;
  /// }
  /// ```
  ///
  /// Runtime: O(size(l1))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that argument `compare` runs in O(1) time and space.
  public func compare<T>(queue1 : Queue<T>, queue2 : Queue<T>, compareItem : (T, T) -> Order.Order) : Order.Order {
    let (i1, i2) = (values queue1, values queue2);
    loop switch (i1.next(), i2.next()) {
      case (?v1, ?v2) switch (compareItem(v1, v2)) {
        case (#equal) ();
        case c return c
      };
      case (null, null) return #equal;
      case (null, _) return #less;
      case (_, null) return #greater
    }
  }

}
