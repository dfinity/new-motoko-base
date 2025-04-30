/// Double-ended queue of a generic element type `T`.
///
/// The interface is purely functional, not imperative, and queues are immutable values.
/// In particular, Queue operations such as push and pop do not update their input queue but, instead, return the
/// value of the modified Queue, alongside any other data.
/// The input queue is left unchanged.
///
/// Examples of use-cases:
/// - Queue (FIFO) by using `pushBack()` and `popFront()`.
/// - Stack (LIFO) by using `pushFront()` and `popFront()`.
/// - Deque (double-ended queue) by using any combination of push/pop operations on either end.
///
/// A Queue is internally implemented as a real-time double-ended queue based on the paper
/// "Real-Time Double-Ended Queue Verified (Proof Pearl)". The implementation maintains
/// worst-case constant time `O(1)` for push/pop operations through gradual rebalancing steps.
///
/// Construction: Create a new queue with the `empty<T>()` function.
///
/// Note on the costs of push and pop functions:
/// * Runtime: `O(1)` amortized costs, `O(size)` worst case cost per single call.
/// * Space: `O(1)` amortized costs, `O(size)` worst case cost per single call.
///
/// `n` denotes the number of elements stored in the queue.
///
/// ```motoko name=import
/// import Queue "mo:base/pure/Queue";
/// ```

import Types "../Types";
import List "List";
import Option "../Option";
import { trap } "../Runtime";
import Iter "../Iter";
import Debug "../Debug";

module {
  /// The real-time queue data structure can be in one of the following states:
  ///
  /// - `#empty`: the queue is empty
  /// - `#one`: the queue contains a single element
  /// - `#two`: the queue contains two elements
  /// - `#three`: the queue contains three elements
  /// - `#idles`: the queue is in the idle state, where `l` and `r` are non-empty stacks of elements fulfilling the size invariant
  /// - `#rebal`: the queue is in the rebalancing state
  public type Queue<T> = {
    #empty;
    #one : T;
    #two : (T, T);
    #three : (T, T, T);
    #idles : (Idle<T>, Idle<T>);
    #rebal : States<T>
  };

  /// Create a new empty queue.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert Queue.isEmpty(queue);
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> = #empty;

  /// Determine whether a queue is empty.
  /// Returns true if `queue` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.empty<Nat>();
  ///   assert Queue.isEmpty(queue);
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty<T>(queue : Queue<T>) : Bool = switch queue {
    case (#empty) true;
    case _ false
  };

  /// Create a new queue comprising a single element.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.singleton(25);
  ///   assert Queue.size(queue) == 1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func singleton<T>(element : T) : Queue<T> = #one(element);

  /// Determine the number of elements contained in a queue.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.singleton(42);
  ///   assert Queue.size(queue) == 1;
  /// }
  /// ```
  ///
  /// Runtime: `O(1)` in Release profile (compiled with `--release` flag), `O(size)` otherwise.
  ///
  /// Space: `O(1)`.
  public func size<T>(queue : Queue<T>) : Nat = switch queue {
    case (#empty) 0;
    case (#one(_)) 1;
    case (#two(_, _)) 2;
    case (#three(_, _, _)) 3;
    case (#idles((l, nL), (r, nR))) {
      // debug assert Stacks.size(l) == nL and Stacks.size(r) == nR;
      nL + nR
    };
    case (#rebal((_, big, small))) BigState.size(big) + SmallState.size(small)
  };

  /// Check if a queue contains a specific element.
  /// Returns true if the queue contains an element equal to `item` according to the `equal` function.
  ///
  /// Note: The order in which elements are visited is undefined, for performance reasons.
  ///
  /// Example:
  /// ```motoko include=import
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
  /// ```motoko include=import
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
    case (#empty) null;
    case (#one(x)) ?x;
    case (#two(x, _)) ?x;
    case (#three(x, _, _)) ?x;
    case (#idles((l, _), _)) Stacks.first(l);
    case (#rebal((dir, big, small))) switch dir {
      case (#left) ?SmallState.peek(small);
      case (#right) ?BigState.peek(big)
    }
  };

  /// Inspect the optional element on the back end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, the back element of `queue`.
  ///
  /// Example:
  /// ```motoko include=import
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

  // helper to rebalance the queue after getting lopsided
  func check<T>(q : Queue<T>) : Queue<T> {
    switch q {
      case (null, n, r) {
        let (a, b) = List.split(r, n / 2);
        (List.reverse b, n, a)
      };
      case (f, n, null) {
        let (a, b) = List.split(f, n / 2);
        (a, n, List.reverse b)
      };
      case q q
    }
  };

  /// Insert a new element on the front end of a queue.
  /// Returns the new queue with `element` in the front followed by the elements of `queue`.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.pushFront(Queue.pushFront(Queue.empty(), 2), 1);
  ///   assert Queue.peekFront(queue) == ?1;
  ///   assert Queue.peekBack(queue) == ?2;
  ///   assert Queue.size(queue) == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushFront<T>(queue : Queue<T>, element : T) : Queue<T> = check(?(element, queue.0), queue.1 + 1, queue.2);

  /// Insert a new element on the back end of a queue.
  /// Returns the new queue with all the elements of `queue`, followed by `element` on the back.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.pushBack(Queue.pushBack(Queue.empty(), 1), 2);
  ///   assert Queue.peekBack(queue) == ?2;
  ///   assert Queue.size(queue) == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func pushBack<T>(queue : Queue<T>, element : T) : Queue<T> = check(queue.0, queue.1 + 1, ?(element, queue.2));

  /// Remove the element on the front end of a queue.
  /// Returns `null` if `queue` is empty. Otherwise, it returns a pair of
  /// the first element and a new queue that contains all the remaining elements of `queue`.
  ///
  /// Example:
  /// ```motoko include=import
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
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
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
  /// Example:
  /// ```motoko include=import
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
  /// Runtime: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(size)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the queue.
  public func popBack<T>(queue : Queue<T>) : ?(Queue<T>, T) = if (queue.1 == 0) null else switch queue {
    case (f, n, ?(i, b)) ?((f, n - 1, b), i);
    case (?(i, null), _, null) ?((null, 0, null), i);
    case _ popBack(check queue)
  };

  /// Turn an iterator into a queue, consuming it.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2, 3, 4].values());
  ///   assert Queue.size(queue) == 5;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func fromIter<T>(iter : Iter<T>) : Queue<T> {
    var queue = empty<T>();
    Iter.forEach(iter, func(t : T) = queue := pushBack(queue, t));
    queue
  };

  /// Convert a queue to an iterator of its elements in front-to-back order.
  ///
  /// Performance note: Creating the iterator needs `O(size)` runtime and space!
  ///
  /// Example:
  /// ```motoko include=import
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
  /// ```motoko include=import
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

  /// Create an iterator over the elements in the queue. The order of the elements is from back to front.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let allGreaterThanOne = Queue.all<Nat>(queue, func n = n > 1);
  ///   assert not allGreaterThanOne; // false because 1 is not > 1
  /// }
  /// ```
  ///
  /// Runtime: `O(1)` to create the iterator and for each `next()` call.
  ///
  /// Space: O(size) as the current implementation uses `values` to iterate over the queue.
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func all<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    for (item in values queue) if (not (predicate item)) return false;
    return true
  };

  /// Compare two queues for equality using a provided equality function to compare their elements.
  /// Two queues are considered equal if they contain the same elements in the same order.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([1, 2, 3].values());
  ///   let hasGreaterThanOne = Queue.any<Nat>(queue, func n = n > 1);
  ///   assert hasGreaterThanOne; // true because 2 and 3 are > 1
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: O(size) as the current implementation uses `values` to iterate over the queue.
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func any<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    for (item in values queue) if (predicate item) return true;
    return false
  };

  /// Call the given function for its side effect, with each queue element in turn.
  /// The order of visiting elements is front-to-back.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   var text = "";
  ///   let queue = Queue.fromIter(["A", "B", "C"].values());
  ///   Queue.forEach<Text>(queue, func n = text #= n);
  ///   assert text == "ABC";
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func forEach<T>(queue : Queue<T>, f : T -> ()) = switch queue {
    case (#empty) ();
    case (#one(x)) f x;
    case (#two(x, y)) { f x; f y };
    case (#three(x, y, z)) { f x; f y; f z };
    // Preserve the order when visiting the elements. Note that the #idles case would require reversing the second stack.
    case _ {
      for (t in values queue) f t
    }
  };

  /// Create a new queue by applying the given function to each element of the original queue.
  /// Note that this operation traverses the elements in arbitrary order.
  ///
  /// Note: The order of visiting elements is undefined with the current implementation.
  /// Example:
  /// ```motoko include=import
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
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func map<T1, T2>(queue : Queue<T1>, f : T1 -> T2) : Queue<T2> = switch queue {
    case (#empty) #empty;
    case (#one(x)) #one(f x);
    case (#two(x, y)) #two(f x, f y);
    case (#three(x, y, z)) #three(f x, f y, f z);
    case (#idles(l, r)) #idles(Idle.map(l, f), Idle.map(r, f));
    case (#rebal(_)) {
      // No reason to rebuild the #rebal state.
      // future work: It could be further optimized by building a balanced #idles state directly since we know the sizes.
      var q = empty<T2>();
      for (t in values queue) q := pushBack(q, f t);
      q
    }
  };

  /// Create a new queue with only those elements of the original queue for which
  /// the given predicate returns true.
  ///
  /// Note: The order of visiting elements is undefined with the current implementation.
  ///
  /// Example:
  /// ```motoko include=import
  /// persistent actor {
  ///   let queue = Queue.fromIter([0, 1, 2, 1].values());
  ///   let filtered = Queue.filter<Nat>(queue, func n = n != 1);
  ///   assert Queue.size(filtered) == 2;
  /// }
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that predicate runs in `O(1)` time and space.
  public func filter<T>(queue : Queue<T>, predicate : T -> Bool) : Queue<T> {
    var q = empty<T>();
    for (t in values queue) if (predicate t) q := pushBack(q, t);
    q
  };

  /// Create a new queue by applying the given function to each element of the original queue
  /// and collecting the results for which the function returns a non-null value.
  ///
  /// Note: The order of visiting elements is undefined with the current implementation.
  ///
  /// Example:
  /// ```motoko include=import
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
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func filterMap<T, U>(queue : Queue<T>, f : T -> ?U) : Queue<U> {
    var q = empty<U>();
    for (t in values queue) {
      switch (f t) {
        case (?x) q := pushBack(q, x);
        case null ()
      }
    };
    q
  };

  /// Convert a queue to its text representation using the provided conversion function.
  /// This function is meant to be used for debugging and testing purposes.
  ///
  /// Example:
  /// ```motoko include=import
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
    var first = true;
    for (t in values queue) {
      if (first) first := false else text #= ", ";
      text #= f(t)
    };
    List.forEach(queue.0, add);
    List.forEach(List.reverse(queue.2), add);
    text # "]"
  };

  /// Reverse the order of elements in a queue.
  /// This operation is cheap, it does NOT require copying the elements.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let queue1 = Queue.fromIter([1, 2].values());
  ///   let queue2 = Queue.fromIter([1, 3].values());
  ///   assert Queue.compare(queue1, queue2, Nat.compare) == #less;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
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

  type Stacks<T> = (left : List<T>, right : List<T>);

  module Stacks {
    public func push<T>((left, right) : Stacks<T>, t : T) : Stacks<T> = (?(t, left), right);

    public func pop<T>(stacks : Stacks<T>) : Stacks<T> = switch stacks {
      case (?(_, leftTail), right) (leftTail, right);
      case (null, ?(_, rightTail)) (null, rightTail);
      case (null, null) stacks
    };

    public func first<T>((left, right) : Stacks<T>) : ?T = switch (left) {
      case (?(h, _)) ?h;
      case (null) do ? { right!.0 }
    };

    public func unsafeFirst<T>((left, right) : Stacks<T>) : T = switch (left) {
      case (?(h, _)) h;
      case (null) Option.unwrap(right).0
    };

    public func isEmpty<T>((left, right) : Stacks<T>) : Bool = List.isEmpty(left) and List.isEmpty(right);

    public func size<T>((left, right) : Stacks<T>) : Nat = List.size(left) + List.size(right);

    public func smallqueue<T>((left, right) : Stacks<T>) : Queue<T> = switch (left, right) {
      case (null, null) #empty;
      case (null, ?(x, null)) #one(x);
      case (?(x, null), null) #one(x);
      case (null, ?(x, ?(y, null))) #two(y, x);
      case (?(x, null), ?(y, null)) #two(y, x);
      case (?(x, ?(y, null)), null) #two(y, x);
      case (null, ?(x, ?(y, ?(z, null)))) #three(z, y, x);
      case (?(x, ?(y, ?(z, null))), null) #three(z, y, x);
      case (?(x, ?(y, null)), ?(z, null)) #three(z, y, x);
      case (?(x, null), ?(y, ?(z, null))) #three(z, y, x);
      case _ (trap "Illegal smallqueue invocation")
    };

    public func map<T, U>((left, right) : Stacks<T>, f : T -> U) : Stacks<U> = (List.map(left, f), List.map(right, f))
  };

  /// Represents an end of the queue that is not in a rebalancing process. It is a stack and its size.
  type Idle<T> = (stacks : Stacks<T>, size : Nat);
  module Idle {
    public func push<T>((stacks, size) : Idle<T>, t : T) : Idle<T> = (Stacks.push(stacks, t), 1 + size);
    public func pop<T>((stacks, size) : Idle<T>) : (T, Idle<T>) = (Stacks.unsafeFirst(stacks), (Stacks.pop(stacks), size - 1 : Nat));
    public func peek<T>((stacks, _) : Idle<T>) : T = Stacks.unsafeFirst(stacks);

    public func map<T, U>((stacks, size) : Idle<T>, f : T -> U) : Idle<U> = (Stacks.map(stacks, f), size)
  };

  /// Stores information about operations that happen during rebalancing but which have not become part of the old state that is being rebalanced.
  ///
  /// - `extra`: newly added elements
  /// - `extraSize`: size of `extra`
  /// - `old`: elements contained before the rebalancing process
  /// - `targetSize`: the number of elements which will be contained after the rebalancing is finished
  type Current<T> = (extra : List<T>, extraSize : Nat, old : Stacks<T>, targetSize : Nat);

  module Current {
    public func new<T>(old : Stacks<T>, targetSize : Nat) : Current<T> = (null, 0, old, targetSize);

    public func push<T>((extra, extraSize, old, targetSize) : Current<T>, t : T) : Current<T> = (?(t, extra), 1 + extraSize, old, targetSize);

    public func pop<T>((extra, extraSize, old, targetSize) : Current<T>) : (T, Current<T>) = switch (extra) {
      case (?(h, t)) (h, (t, extraSize - 1 : Nat, old, targetSize));
      case (null) (Stacks.unsafeFirst(old), (null, extraSize, Stacks.pop(old), targetSize - 1 : Nat))
    };

    public func peek<T>((extra, _, old, _) : Current<T>) : T = switch (extra) {
      case (?(h, _)) h;
      case (null) Stacks.unsafeFirst(old)
    };

    public func size<T>((_, extraSize, _, targetSize) : Current<T>) : Nat = extraSize + targetSize
  };

  /// The bigger end of the queue during rebalancing. It is used to split the bigger end of the queue into the new big end and a portion to be added to the small end. Can be in one of the following states:
  ///
  /// - `#big1(cur, big, aux, n)`: Initial stage. Using the step function it takes `n`-elements from the `big` stack and puts them to `aux` in reversed order. `#big1(cur, x1 .. xn : bigTail, [], n) ->* #big1(cur, bigTail, xn .. x1, 0)`. The `bigTail` is later given to the `small` end.
  /// - `#big2(common)`: Is used to reverse the elements from the previous phase to restore the original order. `common = #copy(cur, xn .. x1, [], 0) ->* #copy(cur, [], x1 .. xn, n)`.
  type BigState<T> = {
    #big1 : (Current<T>, Stacks<T>, List<T>, Nat);
    #big2 : CommonState<T>
  };

  module BigState {
    public func push<T>(big : BigState<T>, t : T) : BigState<T> = switch big {
      case (#big1(cur, big, aux, n)) #big1(Current.push(cur, t), big, aux, n);
      case (#big2(state)) #big2(CommonState.push(state, t))
    };

    public func pop<T>(big : BigState<T>) : (T, BigState<T>) = switch big {
      case (#big1(cur, big, aux, n)) {
        let (x, cur2) = Current.pop(cur);
        (x, #big1(cur2, big, aux, n))
      };
      case (#big2(state)) {
        let (x, state2) = CommonState.pop(state);
        (x, #big2(state2))
      }
    };

    public func peek<T>(big : BigState<T>) : T = switch big {
      case (#big1(cur, _, _, _)) Current.peek(cur);
      case (#big2(state)) CommonState.peek(state)
    };

    public func step<T>(big : BigState<T>) : BigState<T> = switch big {
      case (#big1(cur, big, aux, n)) {
        if (n == 0)
        #big2(CommonState.norm(#copy(cur, aux, null, 0))) else
        #big1(cur, Stacks.pop(big), ?(Stacks.unsafeFirst(big), aux), n - 1 : Nat)
      };
      case (#big2(state)) #big2(CommonState.step(state))
    };

    public func size<T>(big : BigState<T>) : Nat = switch big {
      case (#big1(cur, _, _, _)) Current.size(cur);
      case (#big2(state)) CommonState.size(state)
    };

    public func current<T>(big : BigState<T>) : Current<T> = switch big {
      case (#big1(cur, _, _, _)) cur;
      case (#big2(state)) CommonState.current(state)
    }
  };

  /// The smaller end of the queue during rebalancing. Can be in one of the following states:
  ///
  /// - `#small1(cur, small, aux)`: Initial stage. Using the step function the original elements are reversed. `#small1(cur, s1 .. sn, []) ->* #small1(cur, [], sn .. s1)`, note that `aux` is initially empty, at the end contains the reversed elements from the small stack.
  /// - `#small2(cur, aux, big, new, size)`: Using the step function the newly transfered tail from the bigger end is reversed on top of the `new` list. `#small2(cur, sn .. s1, b1 .. bm, [], 0) ->* #small2(cur, sn .. s1, [], bm .. b1, m)`, note that `aux` is the reversed small stack from the previous phase, `new` is initially empty, `size` corresponds to the size of `new`.
  /// - `#small3(common)`: Is used to reverse the elements from the two previous phases again to get them again in the original order. `#copy(cur, sn .. s1, bm .. b1, m) ->* #copy(cur, [], s1 .. sn : bm .. b1, n + m)`, note that the correct order of the elements from the big stack is reversed.
  type SmallState<T> = {
    #small1 : (Current<T>, Stacks<T>, List<T>);
    #small2 : (Current<T>, List<T>, Stacks<T>, List<T>, Nat);
    #small3 : CommonState<T>
  };

  module SmallState {
    public func push<T>(state : SmallState<T>, t : T) : SmallState<T> = switch state {
      case (#small1(cur, small, aux)) #small1(Current.push(cur, t), small, aux);
      case (#small2(cur, aux, big, new, newN)) #small2(Current.push(cur, t), aux, big, new, newN);
      case (#small3(common)) #small3(CommonState.push(common, t))
    };

    public func pop<T>(state : SmallState<T>) : (T, SmallState<T>) = switch state {
      case (#small1(cur0, small, aux)) {
        let (t, cur) = Current.pop(cur0);
        (t, #small1(cur, small, aux))
      };
      case (#small2(cur0, aux, big, new, newN)) {
        let (t, cur) = Current.pop(cur0);
        (t, #small2(cur, aux, big, new, newN))
      };
      case (#small3(common0)) {
        let (t, common) = CommonState.pop(common0);
        (t, #small3(common))
      }
    };

    public func peek<T>(state : SmallState<T>) : T = switch state {
      case (#small1(cur, _, _)) Current.peek(cur);
      case (#small2(cur, _, _, _, _)) Current.peek(cur);
      case (#small3(common)) CommonState.peek(common)
    };

    public func step<T>(state : SmallState<T>) : SmallState<T> = switch state {
      case (#small1(cur, small, aux)) {
        if (Stacks.isEmpty(small)) state else #small1(cur, Stacks.pop(small), ?(Stacks.unsafeFirst(small), aux))
      };
      case (#small2(cur, aux, big, new, newN)) {
        if (Stacks.isEmpty(big)) #small3(CommonState.norm(#copy(cur, aux, new, newN))) else #small2(cur, aux, Stacks.pop(big), ?(Stacks.unsafeFirst(big), new), 1 + newN)
      };
      case (#small3(common)) #small3(CommonState.step(common))
    };

    public func size<T>(state : SmallState<T>) : Nat = switch state {
      case (#small1(cur, _, _)) Current.size(cur);
      case (#small2(cur, _, _, _, _)) Current.size(cur);
      case (#small3(common)) CommonState.size(common)
    };

    public func current<T>(state : SmallState<T>) : Current<T> = switch state {
      case (#small1(cur, _, _)) cur;
      case (#small2(cur, _, _, _, _)) cur;
      case (#small3(common)) CommonState.current(common)
    }
  };

  type CopyState<T> = { #copy : (Current<T>, List<T>, List<T>, Nat) };

  /// Represents the last rebalancing phase of both small and big ends of the queue. It is used to reverse the elements from the previous phases to restore the original order. It can be in one of the following states:
  ///
  /// - `#copy(cur, aux, new, sizeOfNew)`: Puts the elements from `aux` in reversed order on top of `new`. `#copy(cur, xn .. x1, new, sizeOfNew) ->* #copy(cur, [], x1 .. xn : new, n + sizeOfNew)`.
  /// - `#idle(cur, idle)`: The rebalancing process is done and the queue is in the idle state.
  type CommonState<T> = CopyState<T> or { #idle : (Current<T>, Idle<T>) };

  module CommonState {
    public func step<T>(common : CommonState<T>) : CommonState<T> = switch common {
      case (#copy copy) {
        let (cur, aux, new, sizeOfNew) = copy;
        let (_, _, _, targetSize) = cur;
        norm(if (sizeOfNew < targetSize) #copy(cur, unsafeTail(aux), ?(unsafeHead(aux), new), 1 + sizeOfNew) else #copy copy)
      };
      case (#idle(_, _)) common
    };

    public func norm<T>(copy : CopyState<T>) : CommonState<T> {
      let #copy(cur, _, new, sizeOfNew) = copy;
      let (extra, extraSize, _, targetSize) = cur;
      // debug assert sizeOfNew <= targetSize;
      if (sizeOfNew >= targetSize) {
        #idle(cur, ((extra, new), extraSize + sizeOfNew)) // note: aux can be non-empty, thus ignored here, when the target size decreases after pop operations
      } else copy
    };

    public func push<T>(common : CommonState<T>, t : T) : CommonState<T> = switch common {
      case (#copy(cur, aux, new, sizeOfNew)) #copy(Current.push(cur, t), aux, new, sizeOfNew);
      case (#idle(cur, idle)) #idle(Current.push(cur, t), Idle.push(idle, t)) // yes, push to both
    };

    public func pop<T>(common : CommonState<T>) : (T, CommonState<T>) = switch common {
      case (#copy(cur, aux, new, sizeOfNew)) {
        let (t, cur2) = Current.pop(cur);
        (t, norm(#copy(cur2, aux, new, sizeOfNew)))
      };
      case (#idle(cur, idle)) {
        let (t, idle2) = Idle.pop(idle);
        (t, #idle(Current.pop(cur).1, idle2))
      }
    };

    public func peek<T>(common : CommonState<T>) : T = switch common {
      case (#copy(cur, _, _, _)) Current.peek(cur);
      case (#idle(_, idle)) Idle.peek(idle)
    };

    public func size<T>(common : CommonState<T>) : Nat = switch common {
      case (#copy(cur, _, _, _)) Current.size(cur);
      case (#idle(_, (_, size))) size
    };

    public func current<T>(common : CommonState<T>) : Current<T> = switch common {
      case (#copy(cur, _, _, _)) cur;
      case (#idle(cur, _)) cur
    }
  };

  type States<T> = (
    direction : Direction,
    bigState : BigState<T>,
    smallState : SmallState<T>
  );

  module States {
    public func step<T>(states : States<T>) : States<T> = switch states {
      case (dir, #big1(_, bigTail, _, 0), #small1(currentS, _, auxS)) {
        (dir, BigState.step(states.1), #small2(currentS, auxS, bigTail, null, 0))
      };
      case (dir, big, small) (dir, BigState.step(big), SmallState.step(small))
    }
  };

  type Direction = { #left; #right };

  public func idlesInvariant<T>(((l, nL), (r, nR)) : (Idle<T>, Idle<T>)) : Bool = Stacks.size(l) == nL and Stacks.size(r) == nR and 3 * nL >= nR and 3 * nR >= nL;

  type List<T> = Types.Pure.List<T>;
  type Iter<T> = Types.Iter<T>;
  func unsafeHead<T>(l : List<T>) : T = Option.unwrap(l).0;
  func unsafeTail<T>(l : List<T>) : List<T> = Option.unwrap(l).1
}
