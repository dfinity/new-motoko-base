/// Double-ended queue of a generic element type `T`.
///
/// The interface is purely functional, not imperative, and deques are immutable values.
/// In particular, Deque operations such as push and pop do not update their input deque but, instead, return the
/// value of the modified Deque, alongside any other data.
/// The input deque is left unchanged.
///
/// Examples of use-cases:
/// - Queue (FIFO) by using `pushBack()` and `popFront()`.
/// - Stack (LIFO) by using `pushFront()` and `popFront()`.
/// - Deque (double-ended queue) by using any combination of push/pop operations on either end.
///
/// A Deque is internally implemented as a real-time double-ended queue based on the paper
/// "Real-Time Double-Ended Queue Verified (Proof Pearl)". The implementation maintains
/// worst-case constant time `O(1)` for push/pop operations through gradual rebalancing steps.
///
/// Construction: Create a new deque with the `empty<T>()` function.
///
/// Note that some operations that traverse the elements of the deque (e.g. `forEach`, `values`) preserve the order of the elements,
/// whereas others (e.g. `map`, `contains`, `any`) do NOT guarantee that the elements are visited in any order.
/// The order is undefined to avoid allocations, making these operations more efficient.

import Types "../Types";
import List "List";
import Option "../Option";
import { trap } "../Runtime";
import Iter "../Iter";

module {
  /// The real-time deque data structure can be in one of the following states:
  ///
  /// - `#empty`: the deque is empty
  /// - `#one`: the deque contains a single element
  /// - `#two`: the deque contains two elements
  /// - `#three`: the deque contains three elements
  /// - `#idles`: the deque is in the idle state, where `l` and `r` are non-empty stacks of elements fulfilling the size invariant
  /// - `#rebal`: the deque is in the rebalancing state
  public type Deque<T> = {
    #empty;
    #one : T;
    #two : (T, T);
    #three : (T, T, T);
    #idles : (Idle<T>, Idle<T>);
    #rebal : States<T>
  };

  /// Create a new empty deque.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// Deque.empty<Nat>()
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Deque<T> = #empty;

  /// Determine whether a deque is empty.
  /// Returns true if `deque` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.empty<Nat>();
  /// Deque.isEmpty(deque) // => true
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty<T>(deque : Deque<T>) : Bool = switch deque {
    case (#empty) true;
    case _ false
  };

  /// Create a new deque comprising a single element.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// Deque.singleton<Nat>(25)
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func singleton<T>(element : T) : Deque<T> = #one(element);

  /// Determine the number of elements contained in a deque.
  ///
  /// Example:
  /// ```motoko
  /// import {singleton; size} "mo:new-base/Deque";
  ///
  /// let deque = singleton<Nat>(42);
  /// size(deque) // => 1
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func size<T>(deque : Deque<T>) : Nat = switch deque {
    case (#empty) 0;
    case (#one(_)) 1;
    case (#two(_, _)) 2;
    case (#three(_, _, _)) 3;
    case (#idles((l, nL), (r, nR))) {
      debug assert Stacks.size(l) == nL and Stacks.size(r) == nR;
      nL + nR
    };
    case (#rebal((_, big, small))) BigState.size(big) + SmallState.size(small)
  };

  /// Test if a deque contains a given value.
  /// Returns true if the deque contains the item, otherwise false.
  /// Note that this operation traverses the elements in arbitrary order.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  /// import Nat "mo:new-base/Nat";
  ///
  /// let deque = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// Deque.contains(deque, Nat.equal, 1) // => true
  /// ```
  ///
  /// Note that the order in which the elements from the `deque` are checked is undefined and may vary.
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func contains<T>(deque : Deque<T>, eq : (T, T) -> Bool, item : T) : Bool = switch deque {
    case (#empty) false;
    case (#one(x)) eq(x, item);
    case (#two(x, y)) eq(x, item) or eq(y, item);
    case (#three(x, y, z)) eq(x, item) or eq(y, item) or eq(z, item);
    case (#idles(((l1, l2), _), ((r1, r2), _))) List.contains(l1, eq, item) or List.contains(l2, eq, item) or List.contains(r2, eq, item) or List.contains(r1, eq, item); // note that the order of the right stack is reversed, but for this operation it does not matter
    case (#rebal((_, big, small))) {
      let (extraB, _, (oldB1, oldB2), _) = BigState.current(big);
      let (extraS, _, (oldS1, oldS2), _) = SmallState.current(small);
      // note that the order is one of the stacks is reversed (depending on the `direction` field), but for this operation it does not matter
      List.contains(extraB, eq, item) or List.contains(oldB1, eq, item) or List.contains(oldB2, eq, item) or List.contains(extraS, eq, item) or List.contains(oldS1, eq, item) or List.contains(oldS2, eq, item)
    }
  };

  /// Inspect the optional element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the front element of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// Deque.peekFront(deque) // => ?1
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekFront<T>(deque : Deque<T>) : ?T = switch deque {
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

  /// Inspect the optional element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the back element of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// Deque.peekBack(deque) // => ?2
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func peekBack<T>(deque : Deque<T>) : ?T = switch deque {
    case (#empty) null;
    case (#one(x)) ?x;
    case (#two(_, y)) ?y;
    case (#three(_, _, z)) ?z;
    case (#idles(_, (r, _))) Stacks.first(r);
    case (#rebal((dir, big, small))) switch dir {
      case (#left) ?BigState.peek(big);
      case (#right) ?SmallState.peek(small)
    }
  };

  /// Insert a new element on the front end of a deque.
  /// Returns the new deque with `element` in the front followed by the elements of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1) // deque with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(1)` worst-case!
  ///
  /// Space: `O(1)` worst-case!
  public func pushFront<T>(deque : Deque<T>, element : T) : Deque<T> = switch deque {
    case (#empty) #one(element);
    case (#one(y)) #two(element, y);
    case (#two(y, z)) #three(element, y, z);
    case (#three(a, b, c)) {
      let i1 = ((?(element, ?(a, null)), null), 2);
      let i2 = ((?(c, ?(b, null)), null), 2);
      #idles(i1, i2)
    };
    case (#idles(l0, (r, nR))) {
      let (l, nL) = Idle.push(l0, element); // enque the element to the left end
      // check if the size invariant still holds
      if (3 * nR >= nL) {
        debug assert 3 * nL >= nR;
        #idles((l, nL), (r, nR))
      } else {
        // initiate the rebalancing process
        let targetSizeL = nL - nR - 1 : Nat;
        let targetSizeR = 2 * nR + 1;
        debug assert targetSizeL + targetSizeR == nL + nR;
        let big = #big1(Current.new(l, targetSizeL), l, null, targetSizeL);
        let small = #small1(Current.new(r, targetSizeR), r, null);
        let states = (#right, big, small);
        let states6 = States.step(States.step(States.step(States.step(States.step(States.step(states))))));
        #rebal(states6)
      }
    };
    // if the deque is in the middle of a rebalancing process: push the element and advance the rebalancing process by 4 steps
    // move back into the idle state if the rebalancing is done
    case (#rebal((dir, big0, small0))) switch dir {
      case (#right) {
        let big = BigState.push(big0, element);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        debug assert states4.0 == #right;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(big, small);
            #idles(big, small)
          };
          case _ #rebal(states4)
        }
      };
      case (#left) {
        let small = SmallState.push(small0, element);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        debug assert states4.0 == #left;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(small, big);
            #idles(small, big) // swapped because dir=left
          };
          case _ #rebal(states4)
        }
      }
    }
  };

  /// Insert a new element on the back end of a deque.
  /// Returns the new deque with all the elements of `deque`, followed by `element` on the back.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2) // deque with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(1)` worst-case!
  ///
  /// Space: `O(1)` worst-case!
  public func pushBack<T>(deque : Deque<T>, element : T) : Deque<T> = reverse(pushFront(reverse(deque), element));

  /// Remove the element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of
  /// the first element and a new deque that contains all the remaining elements of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  /// import Debug "mo:new-base/Debug";
  ///
  /// let initial = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1); // initial deque with elements [1, 2]
  /// Deque.popFront(initial) // => ?(1, [2])
  /// ```
  ///
  /// Runtime: `O(1)` worst-case!
  ///
  /// Space: `O(1)` worst-case!
  public func popFront<T>(deque : Deque<T>) : ?(T, Deque<T>) = switch deque {
    case (#empty) null;
    case (#one(x)) ?(x, #empty);
    case (#two(x, y)) ?(x, #one(y));
    case (#three(x, y, z)) ?(x, #two(y, z));
    case (#idles(l0, (r, nR))) {
      let (x, (l, nL)) = Idle.pop(l0);
      if (3 * nL >= nR) {
        ?(x, #idles((l, nL), (r, nR)))
      } else if (nL >= 1) {
        let targetSizeL = 2 * nL + 1;
        let targetSizeR = nR - nL - 1 : Nat;
        debug assert targetSizeL + targetSizeR == nL + nR;
        let small = #small1(Current.new(l, targetSizeL), l, null);
        let big = #big1(Current.new(r, targetSizeR), r, null, targetSizeR);
        let states = (#left, big, small);
        let states6 = States.step(States.step(States.step(States.step(States.step(States.step(states))))));
        ?(x, #rebal(states6))
      } else {
        ?(x, Stacks.smallDeque(r))
      }
    };
    case (#rebal((dir, big0, small0))) switch dir {
      case (#left) {
        let (x, small) = SmallState.pop(small0);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        debug assert states4.0 == #left;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(small, big);
            ?(x, #idles(small, big))
          };
          case _ ?(x, #rebal(states4))
        }
      };
      case (#right) {
        let (x, big) = BigState.pop(big0);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        debug assert states4.0 == #right;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(big, small);
            ?(x, #idles(big, small))
          };
          case _ ?(x, #rebal(states4))
        }
      }
    }
  };

  /// Remove the element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of
  /// a new deque that contains the remaining elements of `deque`
  /// and, as the second pair item, the removed back element.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  /// import Debug "mo:new-base/Debug";
  ///
  /// let initial = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2); // initial deque with elements [1, 2]
  /// Deque.popBack(initial) // => ?(2, [1])
  /// ```
  ///
  /// Runtime: `O(1)` worst-case!
  ///
  /// Space: `O(1)` worst-case!
  public func popBack<T>(deque : Deque<T>) : ?(Deque<T>, T) = do ? {
    let (x, deque2) = popFront(reverse(deque))!;
    (reverse(deque2), x)
  };

  /// Turn an iterator into a deque, consuming it.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// Deque.fromIter([1, 2, 3].vals()) // deque with elements [1, 2, 3], 1 at the front, 3 at the back
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func fromIter<T>(iter : Iter<T>) : Deque<T> {
    var deque = empty<T>();
    Iter.forEach(iter, func(t : T) = deque := pushBack(deque, t));
    deque
  };

  /// Create an iterator over the elements in the deque. The order of the elements is from front to back.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// let iter = Deque.values(deque);
  /// Array.fromIter(iter) // => [1, 2, 3]
  /// ```
  ///
  /// Runtime: `O(1)` to create the iterator and for each `next()` call.
  ///
  /// Space: `O(1)` to create the iterator and for each `next()` call.
  public func values<T>(deque : Deque<T>) : Iter.Iter<T> {
    object {
      var current = deque;
      public func next() : ?T {
        switch (popFront(current)) {
          case null null;
          case (?result) {
            current := result.1;
            ?result.0
          }
        }
      }
    }
  };

  /// Create an iterator over the elements in the deque. The order of the elements is from back to front.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// let iter = Deque.valuesRev(deque);
  /// Array.fromIter(iter) // => [3, 2, 1]
  /// ```
  ///
  /// Runtime: `O(1)` to create the iterator and for each `next()` call.
  ///
  /// Space: `O(1)` to create the iterator and for each `next()` call.
  public func valuesRev<T>(deque : Deque<T>) : Iter.Iter<T> {
    object {
      var current = deque;
      public func next() : ?T {
        switch (popBack(current)) {
          case null null;
          case (?result) {
            current := result.0;
            ?result.1
          }
        }
      }
    }
  };

  /// Compare two deques for equality using a provided equality function to compare their elements.
  /// Two deques are considered equal if they contain the same elements in the same order.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  /// import Nat "mo:new-base/Nat";
  ///
  /// let deque1 = Deque.fromIter([1, 2, 3].vals());
  /// let deque2 = Deque.fromIter([1, 2, 3].vals());
  /// Deque.equal(deque1, deque2, Nat.equal) // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func equal<T>(deque1 : Deque<T>, deque2 : Deque<T>, equality : (T, T) -> Bool) : Bool = switch (popFront deque1, popFront deque2) {
    case (null, null) true;
    case (?((x1, deque1Tail)), ?((x2, deque2Tail))) equality(x1, x2) and equal(deque1Tail, deque2Tail, equality); // Note that this is tail recursive (`and` is expanded to `if`).
    case _ false
  }; // todo: confusing high Space complexity, but it cannot be avoided -- consider removing the operation all together

  /// Return true if the given predicate is true for all deque elements.
  /// Note that this operation traverses the elements in arbitrary order.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([2, 4, 6].vals());
  /// Deque.all(deque, func n = n % 2 == 0) // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that predicate runs in `O(1)` time and space.
  public func all<T>(deque : Deque<T>, predicate : T -> Bool) : Bool = switch deque {
    case (#empty) true;
    case (#one(x)) predicate x;
    case (#two(x, y)) predicate x and predicate y;
    case (#three(x, y, z)) predicate x and predicate y and predicate z;
    case (#idles(((l1, l2), _), ((r1, r2), _))) List.all(l1, predicate) and List.all(l2, predicate) and List.all(r2, predicate) and List.all(r1, predicate); // note that the order of the right stack is reversed, but for thisation it does not matter
    case (#rebal(_, big, small)) {
      let (extraB, _, (oldB1, oldB2), _) = BigState.current(big);
      let (extraS, _, (oldS1, oldS2), _) = SmallState.current(small);
      // note that the order is one of the stacks is reversed (depending on the `direction` field), but for this operation it does not matter
      List.all(extraB, predicate) and List.all(oldB1, predicate) and List.all(oldB2, predicate) and List.all(extraS, predicate) and List.all(oldS1, predicate) and List.all(oldS2, predicate)
    }
  };

  /// Return true if the given predicate is true for any deque element.
  /// Note that this operation traverses the elements in arbitrary order.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// Deque.any(deque, func n = n > 2) // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that predicate runs in `O(1)` time and space.
  public func any<T>(deque : Deque<T>, predicate : T -> Bool) : Bool = switch deque {
    case (#empty) false;
    case (#one(x)) predicate x;
    case (#two(x, y)) predicate x or predicate y;
    case (#three(x, y, z)) predicate x or predicate y or predicate z;
    case (#idles(((l1, l2), _), ((r1, r2), _))) List.any(l1, predicate) or List.any(l2, predicate) or List.any(r2, predicate) or List.any(r1, predicate); // note that the order of the right stack is reversed, but for thisation it does not matter
    case (#rebal(_, big, small)) {
      let (extraB, _, (oldB1, oldB2), _) = BigState.current(big);
      let (extraS, _, (oldS1, oldS2), _) = SmallState.current(small);
      // note that the order is one of the stacks is reversed (depending on the `direction` field), but for this operation it does not matter
      List.any(extraB, predicate) or List.any(oldB1, predicate) or List.any(oldB2, predicate) or List.any(extraS, predicate) or List.any(oldS1, predicate) or List.any(oldS2, predicate)
    }
  };

  /// Call the given function for its side effect on each deque element in order: from front to back.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// var sum = 0;
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// Deque.forEach(deque, func n = sum += n);
  /// sum // => 6
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func forEach<T>(deque : Deque<T>, f : T -> ()) = switch deque {
    case (#empty) ();
    case (#one(x)) f x;
    case (#two(x, y)) { f x; f y };
    case (#three(x, y, z)) { f x; f y; f z };
    // Preserve the order when visiting the elements. Note that the #idles case would require reversing the second stack.
    case _ {
      for (t in values deque) f t
    } // todo: consider removing this operation, users can use Iter.forEach instead as this is not efficient
  };

  /// Create a new deque by applying the given function to each element of the original deque.
  /// Note that this operation traverses the elements in arbitrary order.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  /// import Nat "mo:new-base/Nat";
  ///
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// let mapped = Deque.map(deque, func n = n * 2) // deque with elements [2, 4, 6]
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func map<T1, T2>(deque : Deque<T1>, f : T1 -> T2) : Deque<T2> = switch deque {
    case (#empty) #empty;
    case (#one(x)) #one(f x);
    case (#two(x, y)) #two(f x, f y);
    case (#three(x, y, z)) #three(f x, f y, f z);
    case (#idles(l, r)) #idles(Idle.map(l, f), Idle.map(r, f));
    case (#rebal(_)) {
      // No reason to rebuild the #rebal state.
      // future work: It could be further optimized by building a balanced #idles state directly since we know the sizes.
      var q = empty<T2>();
      for (t in values deque) q := pushBack(q, f t);
      q
    }
  };

  /// Create a new deque with only those elements of the original deque for which
  /// the given predicate returns true.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3, 4].vals());
  /// let filtered = Deque.filter(deque, func n = n % 2 == 0) // deque with elements [2, 4]
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that predicate runs in `O(1)` time and space.
  public func filter<T>(deque : Deque<T>, predicate : T -> Bool) : Deque<T> {
    var q = empty<T>();
    for (t in values deque) if (predicate t) q := pushBack(q, t);
    q
  };

  /// Create a new deque by applying the given function to each element of the original deque
  /// and collecting the results for which the function returns a non-null value.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3, 4].vals());
  /// let filtered = Deque.filterMap(deque, func n = if n % 2 == 0 then ?n else null) // deque with elements [2, 4]
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func filterMap<T, U>(deque : Deque<T>, f : T -> ?U) : Deque<U> {
    var q = empty<U>();
    for (t in values deque) {
      switch (f t) {
        case (?x) q := pushBack(q, x);
        case null ()
      }
    };
    q
  };

  /// Create a `Text` representation of a deque for debugging purposes.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// Deque.toText(deque, Nat.toText) // => "PureDeque[1, 2, 3]"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that f runs in `O(1)` time and space.
  public func toText<T>(deque : Deque<T>, f : T -> Text) : Text {
    var text = "PureDeque[";
    var first = true;
    for (t in values deque) {
      if (first) first := false else text #= ", ";
      text #= f(t)
    };
    text # "]"
  };

  /// Reverse the order of elements in a deque.
  /// This operation is cheap, it does NOT require copying the elements.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:new-base/Deque";
  ///
  /// let deque = Deque.fromIter([1, 2, 3].vals());
  /// Deque.toText(Deque.reverse(deque), Nat.toText) // => "PureDeque[3, 2, 1]"
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func reverse<T>(deque : Deque<T>) : Deque<T> = switch deque {
    case (#empty) deque;
    case (#one(_)) deque;
    case (#two(x, y)) #two(y, x);
    case (#three(x, y, z)) #three(z, y, x);
    case (#idles(l, r)) #idles(r, l);
    case (#rebal(#left, big, small)) #rebal(#right, big, small);
    case (#rebal(#right, big, small)) #rebal(#left, big, small)
  };

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

    public func smallDeque<T>((left, right) : Stacks<T>) : Deque<T> = switch (left, right) {
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
      case _ (trap "Illegal smallDeque invocation")
    };

    public func map<T, U>((left, right) : Stacks<T>, f : T -> U) : Stacks<U> = (List.map(left, f), List.map(right, f))
  };

  /// Represents an end of the deque that is not in a rebalancing process. It is a stack and its size.
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

  /// The bigger end of the deque during rebalancing. It is used to split the bigger end of the deque into the new big end and a portion to be added to the small end. Can be in one of the following states:
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

  /// The smaller end of the deque during rebalancing. Can be in one of the following states:
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

  /// Represents the last rebalancing phase of both small and big ends of the deque. It is used to reverse the elements from the previous phases to restore the original order. It can be in one of the following states:
  ///
  /// - `#copy(cur, aux, new, sizeOfNew)`: Puts the elements from `aux` in reversed order on top of `new`. `#copy(cur, xn .. x1, new, sizeOfNew) ->* #copy(cur, [], x1 .. xn : new, n + sizeOfNew)`.
  /// - `#idle(cur, idle)`: The rebalancing process is done and the deque is in the idle state.
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
      debug assert sizeOfNew <= targetSize;
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
  func unsafeTail<T>(l : List<T>) : List<T> = Option.unwrap(l).1;

  // func concatValues<T>(lists : List<List<T>>) : Iter<T> = object {
  //   var ll = lists;
  //   public func next() : ?T {
  //     let ?(list, tailL) = ll else return null;
  //     let ?(h, t) = list else { ll := tailL; return next() };
  //     ll := ?(t, tailL);
  //     ?h
  //   }
  // };

  // // todo: make these reverse operations lazy in the object
  // func concatIdles<T>(((l1, l2), _) : Idle<T>, ((r1, r2), _) : Idle<T>) : Iter<T> = concatValues(?(l1, ?(l2, ?(List.reverse r2, ?(List.reverse r1, null)))));
  // func concatCurrents<T>((extraL, _, (oldL1, oldL2), _) : Current<T>, (extraR, _, (oldR1, oldR2), _) : Current<T>) : Iter<T> = concatValues(?(extraL, ?(oldL1, ?(oldL2, ?(List.reverse oldR2, ?(List.reverse oldR1, ?(List.reverse extraR, null)))))))
}
