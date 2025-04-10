/// Purely-functional, singly-linked lists.

/// A list of type `List<T>` is either `null` or an optional pair of a value of type `T` and a tail, itself of type `List<T>`.
///
/// To use this library, import it using:
///
/// ```motoko name=import
/// import List "mo:base/pure/List";
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   assert List.empty<Nat>() == null;
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func empty<T>() : List<T> = null;

  /// Check whether a list is empty and return true if the list is empty.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   assert List.isEmpty(null);
  ///   assert not List.isEmpty(?(1, null));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, null));
  ///   assert List.size(list) == 2;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func size<T>(list : List<T>) : Nat = (
    func go(n : Nat, list : List<T>) : Nat = switch list {
      case (?(_, t)) go(n + 1, t);
      case null n
    }
  )(0, list);

  /// Check whether the list contains a given value. Uses the provided equality function to compare values.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.contains(list, Nat.equal, 2);
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, null));
  ///   assert List.get<Nat>(list, 1) == ?1;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func get<T>(list : List<T>, n : Nat) : ?T = switch list {
    case (?(h, t)) if (n == 0) ?h else get(t, n - 1 : Nat);
    case null null
  };

  /// Add `item` to the head of `list`, and return the new list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   assert List.pushFront<Nat>(null, 0) == ?(0, null);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func pushFront<T>(list : List<T>, item : T) : List<T> = ?(item, list);

  /// Return the last element of the list, if present.
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, null));
  ///   assert List.last<Nat>(list) == ?1;
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, null));
  ///   assert List.popFront<Nat>(list) == (?0, ?(1, null));
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func popFront<T>(list : List<T>) : (?T, List<T>) = switch list {
    case null (null, null);
    case (?(h, t)) (?h, t)
  };

  /// Reverses the list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.reverse<Nat>(list) == ?(2, ?(1, ?(0, null)));
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func reverse<T>(list : List<T>) : List<T> = (
    func go(acc : List<T>, list : List<T>) : List<T> = switch list {
      case (?(h, t)) go(?(h, acc), t);
      case null acc
    }
  )(null, list);

  /// Call the given function for its side effect, with each list element in turn.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   var sum = 0;
  ///   List.forEach<Nat>(list, func n = sum += n);
  ///   assert sum == 3;
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(list : List<T>, f : T -> ()) = switch list {
    case (?(h, t)) { f h; forEach(t, f) };
    case null ()
  };

  /// Call the given function `f` on each list element and collect the results
  /// in a new list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.map<Nat, Text>(list, Nat.toText) == ?("0", ?("1", ?("2", null)));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.filter<Nat>(list, func n = n != 1) == ?(0, ?(2, null));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.filterMap<Nat, Nat>(
  ///     list,
  ///     func n = if (n > 1) ?(n * 2) else null
  ///   ) == ?(4, ?(6, null));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.mapResult<Nat, Nat, Text>(
  ///     list,
  ///     func n = if (n > 0) #ok(n * 2) else #err "Some element is zero"
  ///   ) == #ok(?(2, ?(4, ?(6, null))));
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.

  public func mapResult<T, R, E>(list : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> = (
    func rev(acc : List<R>, list : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> = switch list {
      case null #ok acc;
      case (?(h, t)) switch (f h) {
        case (#ok fh) rev(?(fh, acc), t, f);
        case (#err e) #err e
      }
    }
  )(null, list, f) |> Result.mapOk(_, func(l : List<R>) : List<R> = reverse l);

  /// Create two new lists from the results of a given function (`f`).
  /// The first list only includes the elements for which the given
  /// function `f` returns true and the second list only includes
  /// the elements for which the function returns false.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.partition<Nat>(list, func n = n != 1) == (?(0, ?(2, null)), ?(1, null));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list1 = ?(0, ?(1, ?(2, null)));
  ///   let list2 = ?(3, ?(4, ?(5, null)));
  ///   assert List.concat<Nat>(list1, list2) == ?(0, ?(1, ?(2, ?(3, ?(4, ?(5, null))))));
  /// }
  /// ```
  ///
  /// Runtime: O(size(l))
  ///
  /// Space: O(size(l))
  public func concat<T>(list1 : List<T>, list2 : List<T>) : List<T> = (
    func revAppend<T>(l : List<T>, m : List<T>) : List<T> = switch l {
      case (?(h, t)) revAppend(t, ?(h, m));
      case null m
    }
  )(reverse list1, list2);

  /// Flatten, or repatedly concatenate, an iterator of lists as a list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Iter "mo:base/Iter";
  ///
  /// persistent actor {
  ///   let lists = [ ?(0, ?(1, ?(2, null))),
  ///                 ?(3, ?(4, ?(5, null))) ];
  ///   assert List.join<Nat>(lists |> Iter.fromArray(_)) == ?(0, ?(1, ?(2, ?(3, ?(4, ?(5, null))))));
  /// }
  /// ```
  ///
  /// Runtime: O(size*size)
  ///
  /// Space: O(size*size)
  public func join<T>(list : Iter.Iter<List<T>>) : List<T> {
    let ?l = list.next() else return null;
    let ls = join list;
    concat(l, ls)
  };

  /// Flatten, or repatedly concatenate, a list of lists as a list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let lists = ?(?(0, ?(1, ?(2, null))),
  ///                ?(?(3, ?(4, ?(5, null))),
  ///                  null));
  ///   assert List.flatten<Nat>(lists) == ?(0, ?(1, ?(2, ?(3, ?(4, ?(5, null))))));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.take<Nat>(list, 2) == ?(0, ?(1, null));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  public func take<T>(list : List<T>, n : Nat) : List<T> = if (n == 0) null else switch list {
    case null null;
    case (?(h, t)) ?(h, take(t, n - 1 : Nat))
  };

  /// Drop the first `n` elements from the given list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.drop<Nat>(list, 2) == ?(2, null);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(1)
  public func drop<T>(list : List<T>, n : Nat) : List<T> = if (n == 0) list else switch list {
    case (?(_, t)) drop(t, n - 1 : Nat);
    case null null
  };

  /// Collapses the elements in `list` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.foldLeft<Nat, Text>(
  ///     list,
  ///     "",
  ///     func (acc, x) = acc # Nat.toText(x)
  ///   ) == "123";
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.foldRight<Nat, Text>(
  ///     list,
  ///     "",
  ///     func (x, acc) = Nat.toText(x) # acc
  ///   ) == "123";
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.find<Nat>(list, func n = n > 1) == ?2;
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert not List.all<Nat>(list, func n = n > 1);
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(1, ?(2, ?(3, null)));
  ///   assert List.any<Nat>(list, func n = n > 1);
  /// }
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
  /// by the given relation `compare`.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list1 = ?(1, ?(2, ?(4, null)));
  ///   let list2 = ?(2, ?(4, ?(6, null)));
  ///   assert List.merge<Nat>(list1, list2, Nat.compare) == ?(1, ?(2, ?(2, ?(4, ?(4, ?(6, null))))));
  /// }
  /// ```
  ///
  /// Runtime: O(size(l1) + size(l2))
  ///
  /// Space: O(size(l1) + size(l2))
  ///
  /// *Runtime and space assumes that `lessThanOrEqual` runs in O(1) time and space.
  // TODO: replace by merge taking a compare : (T, T) -> Order.Order function?
  public func merge<T>(list1 : List<T>, list2 : List<T>, compare : (T, T) -> Order.Order) : List<T> = switch (list1, list2) {
    case (?(h1, t1), ?(h2, t2)) {
      if (compare(h1, h2) != #greater) {
        ?(h1, merge(t1, list2, compare))
      } else if (compare(h2, h1) != #greater) {
        ?(h2, merge(list1, t2, compare))
      } else {
        ?(h1, ?(h2, merge(list1, list2, compare)))
      }
    };
    case (null, _) list2;
    case (_, null) list1
  };

  /// Check if two lists are equal using the given equality function to compare elements.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list1 = ?(1, ?(2, null));
  ///   let list2 = ?(1, ?(2, null));
  ///   assert List.equal<Nat>(list1, list2, Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equalItem` runs in O(1) time and space.
  public func equal<T>(list1 : List<T>, list2 : List<T>, equalItem : (T, T) -> Bool) : Bool = switch (list1, list2) {
    case (null, null) true;
    case (?(h1, t1), ?(h2, t2)) equalItem(h1, h2) and equal(t1, t2, equalItem);
    case _ false
  };

  /// Compare two lists using lexicographic ordering specified by argument function `compareItem`.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list1 = ?(1, ?(2, null));
  ///   let list2 = ?(3, ?(4, null));
  ///   assert List.compare<Nat>(list1, list2, Nat.compare) == #less;
  /// }
  /// ```
  ///
  /// Runtime: O(size(l1))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that argument `compare` runs in O(1) time and space.
  public func compare<T>(list1 : List<T>, list2 : List<T>, compareItem : (T, T) -> Order.Order) : Order.Order = switch (list1, list2) {
    case (?(h1, t1), ?(h2, t2)) switch (compareItem(h1, h2)) {
      case (#equal) compare(t1, t2, compareItem);
      case o o
    };
    case (null, null) #equal;
    case (null, _) #less;
    case _ #greater
  };

  /// Generate a list based on a length and a function that maps from
  /// a list index to a list element.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = List.tabulate<Nat>(3, func n = n * 2);
  ///   assert list == ?(0, ?(2, ?(4, null)));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func tabulate<T>(n : Nat, f : Nat -> T) : List<T> {
    var i = 0;
    var l : List<T> = null;
    while (i < n) {
      l := ?(f i, l);
      i += 1
    };
    reverse l
  };

  /// Create a list with exactly one element.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   assert List.singleton<Nat>(0) == ?(0, null);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func singleton<T>(item : T) : List<T> = ?(item, null);

  /// Create a list of the given length with the same value in each position.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = List.repeat<Char>('a', 3);
  ///   assert list == ?('a', ?('a', ?('a', null)));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  public func repeat<T>(item : T, n : Nat) : List<T> {
    var res : List<T> = null;
    var i : Int = n;
    while (i != 0) {
      i -= 1;
      res := ?(item, res)
    };
    res
  };

  /// Create a list of pairs from a pair of lists.
  ///
  /// If the given lists have different lengths, then the created list will have a
  /// length equal to the length of the smaller list.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list1 = ?(0, ?(1, ?(2, null)));
  ///   let list2 = ?("0", ?("1", null));
  ///   assert List.zip<Nat, Text>(list1, list2) == ?((0, "0"), ?((1, "1"), null));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  /// import Char "mo:base/Char";
  ///
  /// persistent actor {
  ///   let list1 = ?(0, ?(1, ?(2, null)));
  ///   let list2 = ?('a', ?('b', null));
  ///   assert List.zipWith<Nat, Char, Text>(
  ///     list1,
  ///     list2,
  ///     func (n, c) = Nat.toText(n) # Char.toText(c)
  ///   ) == ?("0a", ?("1b", null));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, null)));
  ///   assert List.split(list, 2) == (?(0, ?(1, null)), ?(2, null));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  ///
  /// Space: O(n)
  public func split<T>(list : List<T>, n : Nat) : (List<T>, List<T>) = if (n == 0) (null, list) else switch list {
    case null (null, null);
    case (?(h, t)) {
      let (l1, l2) = split(t, n - 1 : Nat);
      (?(h, l1), l2)
    }
  };

  /// Split the given list into chunks of length `n`.
  /// The last chunk will be shorter if the length of the given list
  /// does not divide by `n` evenly. Traps if `n` = 0.
  ///
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = ?(0, ?(1, ?(2, ?(3, ?(4, null)))));
  ///   assert List.chunks(list, 2) == ?(?(0, ?(1, null)), ?(?(2, ?(3, null)), ?(?(4, null), null)));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let list = List.fromArray<Nat>([3, 1, 4]);
  ///   var text = "";
  ///   for (item in List.values(list)) {
  ///     text #= Nat.toText(item);
  ///   };
  ///   assert text == "314";
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = List.fromArray<Nat>([0, 1, 2, 3, 4]);
  ///   assert list == ?(0, ?(1, ?(2, ?(3, ?(4, null)))));
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = List.fromVarArray<Nat>([var 0, 1, 2, 3, 4]);
  ///   assert list == ?(0, ?(1, ?(2, ?(3, ?(4, null)))));
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromVarArray<T>(array : [var T]) : List<T> = fromArray<T>(Array.fromVarArray<T>(array));

  /// Create an array from a list.
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Array "mo:base/Array";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let array = List.toArray<Nat>(?(0, ?(1, ?(2, ?(3, ?(4, null))))));
  ///   assert Array.equal<Nat>(array, [0, 1, 2, 3, 4], Nat.equal);
  /// }
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
  /// ```motoko
  /// import List "mo:base/pure/List";
  /// import Array "mo:base/Array";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let array = List.toVarArray<Nat>(?(0, ?(1, ?(2, ?(3, ?(4, null))))));
  ///   assert Array.equal<Nat>(Array.fromVarArray(array), [0, 1, 2, 3, 4], Nat.equal);
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func toVarArray<T>(list : List<T>) : [var T] = Array.toVarArray<T>(toArray<T>(list));

  /// Turn an iterator into a list, consuming it.
  /// Example:
  /// ```motoko
  /// import List "mo:base/pure/List";
  ///
  /// persistent actor {
  ///   let list = List.fromIter<Nat>([0, 1, 2, 3, 4].vals());
  ///   assert list == ?(0, ?(1, ?(2, ?(3, ?(4, null)))));
  /// }
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func fromIter<T>(iter : Iter.Iter<T>) : List<T> {
    var result : List<T> = null;
    Iter.forEach<T>(
      iter,
      func x = result := ?(x, result)
    );
    reverse result
  };

  public func toText<T>(list : List<T>, f : T -> Text) : Text {
    var text = "[";
    var first = true;
    forEach(
      list,
      func(item : T) {
        if first {
          first := false
        } else {
          text #= ", "
        };
        text #= f item
      }
    );
    text # "]"
  };

}
