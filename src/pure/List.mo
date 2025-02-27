/// Purely-functional, singly-linked lists.

/// A list of type `List<T>` is either `null` or an optional pair of a value of type `T` and a tail, itself of type `List<T>`.
///
/// To use this library, import it using:
///
/// ```motoko name=initialize
/// import List "mo:base/List";
/// ```

import { Array_tabulate } "mo:⛔";
import Array "../Array";
import Iter "../Iter";
import Order "../Order";
import Result "../Result";
import { trap } "../Runtime";
import Types "../Types";
import Runtime "../Runtime";

module {

  public type List<T> = Types.Pure.List<T>;

  /// Create an empty list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.empty<Nat>() // => null
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func empty<T>() : List<T> = null;

  /// Check whether a list is empty and return true if the list is empty.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.isEmpty<Nat>(null) // => true
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func isEmpty<T>(list : List<T>) : Bool = switch list {
    case null true;
    case _ false
  };

  /// Return the length of the list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.size<Nat>(?(0, ?(1, null))) // => 2
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func size<T>(list : List<T>) : Nat = switch list {
    case null 0;
    case (?(_, t)) 1 + size t
  };

  /// Check whether the list contains a given value. Uses the provided equality function to compare values.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat "mo:base/Nat";
  /// List.contains<Nat>(?(1, ?(2, ?(3, null))), Nat.equal, 2) // => true
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func contains<T>(list : List<T>, equal : (T, T) -> Bool, item : T) : Bool = switch list {
    case (?(h, t)) equal(h, item) or contains(t, equal, item);
    case _ false
  };

  /// Access any item in a list, zero-based.
  ///
  /// NOTE: Indexing into a list is a linear operation, and usually an
  /// indication that a list might not be the best data structure
  /// to use.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.get<Nat>(?(0, ?(1, null)), 1) // => ?1
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func get<T>(list : List<T>, n : Nat) : ?T = switch list {
    case null null;
    case (?(h, t)) if (n == 0) ?h else get(t, n - 1)
  };

  /// Add `item` to the head of `list`, and return the new list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.push<Nat>(null, 0) // => ?(0, null);
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func push<T>(list : List<T>, item : T) : List<T> = ?(item, list);

  /// Return the last element of the list, if present.
  /// Example:
  /// ```motoko include=initialize
  /// List.last<Nat>(?(0, ?(1, null))) // => ?1
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func last<T>(list : List<T>) : ?T = switch list {
    case (?(h, null)) ?h;
    case null null;
    case (?(_, t)) last t
  };

  /// Remove the head of the list, returning the optioned head and the tail of the list in a pair.
  /// Returns `(null, null)` if the list is empty.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.pop<Nat>(?(0, ?(1, null))) // => (?0, ?(1, null))
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func pop<T>(list : List<T>) : (?T, List<T>) = switch list {
    case null (null, null);
    case (?(h, t)) (?h, t)
  };

  /// Reverses the list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.reverse<Nat>(?(0, ?(1, ?(2, null)))) // => ?(2, ?(1, ?(0, null)))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func reverse<T>(list : List<T>) : List<T> {
    func go(acc : List<T>, list : List<T>) : List<T> = switch list {
      case null acc;
      case (?(h, t)) go(?(h, acc), t)
    };
    go(null, list)
  };

  /// Call the given function for its side effect, with each list element in turn.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// var sum = 0;
  /// List.forEach<Nat>(?(0, ?(1, ?(2, null))), func n = sum += n);
  /// sum // => 3
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(list : List<T>, f : T -> ()) = switch list {
    case null ();
    case (?(h, t)) { f h; forEach(t, f) }
  };

  /// Call the given function `f` on each list element and collect the results
  /// in a new list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat = "mo:base/Nat"
  /// List.map<Nat, Text>(?(0, ?(1, ?(2, null))), Nat.toText) // => ?("0", ?("1", ?("2", null))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<T1, T2>(list : List<T1>, f : T1 -> T2) : List<T2> = switch list {
    case null null;
    case (?(h, t)) ?(f h, map(t, f))
  };

  /// Create a new list with only those elements of the original list for which
  /// the given function (often called the _predicate_) returns true.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.filter<Nat>(?(0, ?(1, ?(2, null))), func n = n != 1) // => ?(0, ?(2, null))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func filter<T>(list : List<T>, f : T -> Bool) : List<T> = switch list {
    case null null;
    case (?(h, t)) if (f h) ?(h, filter(t, f)) else filter(t, f)
  };

  /// Call the given function on each list element, and collect the non-null results
  /// in a new list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.filterMap<Nat, Nat>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   func n = if (n > 1) ?(n * 2) else null
  /// ) // => ?(4, ?(6, null))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func filterMap<T, R>(list : List<T>, f : T -> ?R) : List<R> = switch list {
    case null null;
    case (?(h, t)) {
      let ?v = f h else return filterMap(t, f);
      ?(v, filterMap(t, f))
    }
  };

  /// Maps a `Result`-returning function `f` over a `List` and returns either
  /// the first error or a list of successful values.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.mapResult<Nat, Nat, Text>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   func n = if (n > 0) #ok(n * 2) else #err "Some element is zero"
  /// ) // => #ok ?(2, ?(4, ?(6, null))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapResult<T, R, E>(list : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> = switch list {
    case null #ok null;
    case (?(h, t)) {
      switch (f h, mapResult(t, f)) {
        case (#ok r, #ok l) #ok(?(r, l));
        case (#err e, _) #err e;
        case (_, #err e) #err e
      }
    }
  };

  /// Create two new lists from the results of a given function (`f`).
  /// The first list only includes the elements for which the given
  /// function `f` returns true and the second list only includes
  /// the elements for which the function returns false.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.partition<Nat>(?(0, ?(1, ?(2, null))), func n = n != 1) // => (?(0, ?(2, null)), ?(1, null))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func partition<T>(list : List<T>, f : T -> Bool) : (List<T>, List<T>) = switch list {
    case null (null, null);
    case (?(h, t)) {
      let left = f h;
      let (l, r) = partition(t, f);
      if left (?(h, l), r) else (l, ?(h, r))
    }
  };

  /// Append the elements from one list to another list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.concat<Nat>(
  ///   ?(0, ?(1, ?(2, null))),
  ///   ?(3, ?(4, ?(5, null)))
  /// ) // => ?(0, ?(1, ?(2, ?(3, ?(4, ?(5, null))))))
  /// ```
  ///
  /// Runtime: O(size(l))
  ///
  /// Space: O(size(l))
  public func concat<T>(list1 : List<T>, list2 : List<T>) : List<T> = switch list1 {
    case null list2;
    case (?(h, t)) ?(h, concat(t, list2))
  };

  public func join<T>(list : Iter.Iter<List<T>>) : List<T> {
    let ?l = list.next() else return null;
    let ls = join list;
    concat(l, ls)
  };

  /// Flatten, or repatedly concatenate, a list of lists as a list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.flatten<Nat>(
  ///   ?(?(0, ?(1, ?(2, null))),
  ///     ?(?(3, ?(4, ?(5, null))),
  ///       null))
  /// ); // => ?(0, ?(1, ?(2, ?(3, ?(4, ?(5, null))))))
  /// ```
  ///
  /// Runtime: O(size*size)
  ///
  /// Space: O(size*size)
  public func flatten<T>(list : List<List<T>>) : List<T> = foldRight<List<T>, List<T>>(list, null, func(list1, list2) = concat(list1, list2));

  /// Returns the first `n` elements of the given list.
  /// If the given list has fewer than `n` elements, this function returns
  /// a copy of the full input list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.take<Nat>(
  ///   ?(0, ?(1, ?(2, null))),
  ///   2
  /// ); // => ?(0, ?(1, null))
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  public func take<T>(list : List<T>, n : Nat) : List<T> = if (n == 0) null else switch list {
    case null null;
    case (?(h, t)) ?(h, take(t, n - 1))
  };

  /// Drop the first `n` elements from the given list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.drop<Nat>(
  ///   ?(0, ?(1, ?(2, null))),
  ///   2
  /// ); // => ?(2, null)
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(1)
  public func drop<T>(list : List<T>, n : Nat) : List<T> = if (n == 0) list else switch list {
    case null null;
    case (?(h, t)) drop(t, n - 1)
  };

  /// Collapses the elements in `list` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat "mo:base/Nat";
  ///
  /// List.foldLeft<Nat, Text>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   "",
  ///   func (acc, x) = acc # Nat.toText(x)
  /// ) // => "123"
  /// ```
  ///
  /// Runtime: O(size(list))
  ///
  /// Space: O(1) heap, O(1) stack
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldLeft<T, A>(list : List<T>, base : A, combine : (A, T) -> A) : A = switch list {
    case null base;
    case (?(h, t)) foldLeft(t, combine(base, h), combine)
  };

  /// Collapses the elements in `buffer` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat "mo:base/Nat";
  ///
  /// List.foldRight<Nat, Text>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   "",
  ///   func (x, acc) = Nat.toText(x) # acc
  /// ) // => "123"
  /// ```
  ///
  /// Runtime: O(size(list))
  ///
  /// Space: O(1) heap, O(size(list)) stack
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldRight<T, A>(list : List<T>, base : A, combine : (T, A) -> A) : A = switch list {
    case null base;
    case (?(h, t)) combine(h, foldRight(t, base, combine))
  };

  /// Return the first element for which the given predicate `f` is true,
  /// if such an element exists.
  ///
  /// Example:
  /// ```motoko include=initialize
  ///
  /// List.find<Nat>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   func n = n > 1
  /// ); // => ?2
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func find<T>(list : List<T>, f : T -> Bool) : ?T = switch list {
    case null null;
    case (?(h, t)) if (f h) ?h else find(t, f)
  };

  /// Return true if the given predicate `f` is true for all list
  /// elements.
  ///
  /// Example:
  /// ```motoko include=initialize
  ///
  /// List.all<Nat>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   func n = n > 1
  /// ); // => false
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func all<T>(list : List<T>, f : T -> Bool) : Bool = switch list {
    case null true;
    case (?(h, t)) f h and all(t, f)
  };

  /// Return true if there exists a list element for which
  /// the given predicate `f` is true.
  ///
  /// Example:
  /// ```motoko include=initialize
  ///
  /// List.any<Nat>(
  ///   ?(1, ?(2, ?(3, null))),
  ///   func n = n > 1
  /// ) // => true
  /// ```
  ///
  /// Runtime: O(size(list))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func any<T>(list : List<T>, f : T -> Bool) : Bool = switch list {
    case null false;
    case (?(h, t)) f h or any(t, f)
  };

  /// Merge two ordered lists into a single ordered list.
  /// This function requires both list to be ordered as specified
  /// by the given relation `lessThanOrEqual`.
  ///
  /// Example:
  /// ```motoko include=initialize
  ///
  /// List.merge<Nat>(
  ///   ?(1, ?(2, ?(4, null))),
  ///   ?(2, ?(4, ?(6, null))),
  ///   func (n1, n2) = n1 <= n2
  /// ); // => ?(1, ?(2, ?(2, ?(4, ?(4, ?(6, null))))))),
  /// ```
  ///
  /// Runtime: O(size(l1) + size(l2))
  ///
  /// Space: O(size(l1) + size(l2))
  ///
  /// *Runtime and space assumes that `lessThanOrEqual` runs in O(1) time and space.
  // TODO: replace by merge taking a compare : (T, T) -> Order.Order function?
  public func merge<T>(list1 : List<T>, list2 : List<T>, lessThanOrEqual : (T, T) -> Bool) : List<T> = switch (list1, list2) {
    case (?(h1, t1), ?(h2, t2)) {
      if (lessThanOrEqual(h1, h2)) {
        ?(h1, merge(t1, list2, lessThanOrEqual))
      } else if (lessThanOrEqual(h2, h1)) {
        ?(h2, merge(list1, t2, lessThanOrEqual))
      } else {
        ?(h1, ?(h2, merge(list1, list2, lessThanOrEqual)))
      }
    };
    case (null, _) list2;
    case (_, null) list1
  };

  /// Check if two lists are equal using the given equality function to compare elements.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat "mo:base/Nat";
  /// List.equal<Nat>(?(1, ?(2, null)), ?(1, ?(2, null)), Nat.equal) // => true
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equalFunc` runs in O(1) time and space.
  public func equal<T>(list1 : List<T>, list2 : List<T>, equalFunc : (T, T) -> Bool) : Bool = switch (list1, list2) {
    case (null, null) true;
    case (?(h1, t1), ?(h2, t2)) equalFunc(h1, h2) and equal(t1, t2, equalFunc);
    case _ false
  };

  /// Compare two lists using lexicographic ordering specified by argument function `compare`.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat "mo:base/Nat";
  ///
  /// List.compare<Nat>(
  ///   ?(1, ?(2, null)),
  ///   ?(3, ?(4, null)),
  ///   Nat.compare
  /// ) // => #less
  /// ```
  ///
  /// Runtime: O(size(l1))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that argument `compare` runs in O(1) time and space.
  public func compare<T>(list1 : List<T>, list2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    type Order = Order.Order;
    func go(list1 : List<T>, list2 : List<T>, comp : (T, T) -> Order) : Order = switch (list1, list2) {
      case (?(h1, t1), ?(h2, t2)) switch (comp(h1, h2)) {
        case (#equal) go(t1, t2, comp);
        case o o
      };
      case (null, null) #equal;
      case (null, _) #less;
      case _ #greater
    };
    go(list1, list2, compare) // FIXME: only needed because of above shadowing
  };

  /// Generate a list based on a length and a function that maps from
  /// a list index to a list element.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.tabulate<Nat>(
  ///   3,
  ///   func n = n * 2
  /// ) // => ?(0, ?(2, (?4, null)))
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func tabulate<T>(n : Nat, f : Nat -> T) : List<T> {
    func go(at : Nat, n : Nat) : List<T> = if (n == 0) null else ?(f at, go(at + 1, n - 1));
    go(0, n)
  };

  /// Create a list with exactly one element.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.singleton<Nat>(
  ///   0
  /// ) // => ?(0, null)
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func singleton<T>(item : T) : List<T> = ?(item, null);

  /// Create a list of the given length with the same value in each position.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.repeat<Nat>(
  ///   3,
  ///   0
  /// ) // => ?(0, ?(0, ?(0, null)))
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  public func repeat<T>(item : T, n : Nat) : List<T> = if (n == 0) null else ?(item, repeat(item, n - 1));

  /// Create a list of pairs from a pair of lists.
  ///
  /// If the given lists have different lengths, then the created list will have a
  /// length equal to the length of the smaller list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.zip<Nat, Text>(
  ///   ?(0, ?(1, ?(2, null))),
  ///   ?("0", ?("1", null)),
  /// ) // => ?((0, "0"), ?((1, "1"), null))
  /// ```
  ///
  /// Runtime: O(min(size(xs), size(ys)))
  ///
  /// Space: O(min(size(xs), size(ys)))
  public func zip<T, U>(list1 : List<T>, list2 : List<U>) : List<(T, U)> = zipWith<T, U, (T, U)>(list1, list2, func(x, y) = (x, y));

  /// Create a list in which elements are created by applying function `f` to each pair `(x, y)` of elements
  /// occuring at the same position in list `xs` and list `ys`.
  ///
  /// If the given lists have different lengths, then the created list will have a
  /// length equal to the length of the smaller list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// import Nat = "mo:base/Nat";
  /// import Char = "mo:base/Char";
  ///
  /// List.zipWith<Nat, Char, Text>(
  ///   ?(0, ?(1, ?(2, null))),
  ///   ?('a', ?('b', null)),
  ///   func (n, c) = Nat.toText(n) # Char.toText(c)
  /// ) // => ?("0a", ?("1b", null))
  /// ```
  ///
  /// Runtime: O(min(size(xs), size(ys)))
  ///
  /// Space: O(min(size(xs), size(ys)))
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func zipWith<T, U, V>(list1 : List<T>, list2 : List<U>, f : (T, U) -> V) : List<V> = switch (list1, list2) {
    case (?(h1, t1), ?(h2, t2)) ?(f(h1, h2), zipWith(t1, t2, f));
    case _ null
  };

  /// Split the given list at the given zero-based index.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.split<Nat>(
  ///   2,
  ///   ?(0, ?(1, ?(2, null)))
  /// ) // => (?(0, ?(1, null)), ?(2, null))
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  public func split<T>(list : List<T>, n : Nat) : (List<T>, List<T>) = if (n == 0) (null, list) else switch list {
    case null (null, null);
    case (?(h, t)) {
      let (l1, l2) = split(t, n - 1);
      (?(h, l1), l2)
    }
  };

  /// Split the given list into chunks of length `n`.
  /// The last chunk will be shorter if the length of the given list
  /// does not divide by `n` evenly. Traps if `n` = 0.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.chunks<Nat>(
  ///   2,
  ///   ?(0, ?(1, ?(2, ?(3, ?(4, null)))))
  /// )
  /// /* => ?(?(0, ?(1, null)),
  ///         ?(?(2, ?(3, null)),
  ///           ?(?(4, null),
  ///             null)))
  /// */
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func chunks<T>(list : List<T>, n : Nat) : List<List<T>> = switch (split(list, n)) {
    case (null, _) { if (n == 0) trap "pure/List.chunks()"; null };
    case (pre, null) ?(pre, null);
    case (pre, post) ?(pre, chunks(post, n))
  };

  /// Returns an iterator to the elements in the list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// var p = "";
  /// for (e in List.values([3, 1, 4]))
  ///   p #= debug_show e;
  /// p // => "314"
  /// ```
  public func values<T>(list : List<T>) : Iter.Iter<T> = object {
    var l = list;
    public func next() : ?T = switch l {
      case null null;
      case (?(h, t)) {
        l := t;
        ?h
      }
    }
  };

  /// Convert an array into a list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.fromArray<Nat>([0, 1, 2, 3, 4])
  /// // =>  ?(0, ?(1, ?(2, ?(3, ?(4, null)))))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromArray<T>(array : [T]) : List<T> {
    func go(from : Nat) : List<T> = if (from < array.size()) ?(array.get from, go(from + 1)) else null;
    go 0
  };

  /// Convert a mutable array into a list.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// List.fromVarArray<Nat>([var 0, 1, 2, 3, 4])
  /// // =>  ?(0, ?(1, ?(2, ?(3, ?(4, null)))))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromVarArray<T>(array : [var T]) : List<T> = fromArray<T>(Array.fromVarArray<T>(array));

  /// Create an array from a list.
  /// Example:
  /// ```motoko include=initialize
  /// List.toArray<Nat>(?(0, ?(1, ?(2, ?(3, ?(4, null))))))
  /// // => [0, 1, 2, 3, 4]
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toArray<T>(list : List<T>) : [T] {
    var l = list;
    Array_tabulate<T>(size list, func _ { let ?(h, t) = l else Runtime.trap("List.toArray(): unreachable"); l := t; h })
  };

  /// Create a mutable array from a list.
  /// Example:
  /// ```motoko include=initialize
  /// List.toVarArray<Nat>(?(0, ?(1, ?(2, ?(3, ?(4, null))))))
  /// // => [var 0, 1, 2, 3, 4]
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toVarArray<T>(list : List<T>) : [var T] = Array.toVarArray<T>(toArray<T>(list));

  /// Turn an iterator into a list, consuming it.
  /// Example:
  /// ```motoko include=initialize
  /// List.fromIter<Nat>([0, 1, 2, 3, 4].values())
  /// // => ?(0, ?(1, ?(2, ?(3, ?(4, null))))))
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromIter<T>(iter : Iter.Iter<T>) : List<T> = switch (iter.next()) {
    case null null;
    case (?item) ?(item, fromIter iter)
  };

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
