/// Mutable array utilities.

import Iter "IterType";
import Order "Order";
import Result "Result";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public func empty<T>() : [var T] = [var];

  public func init<T>(size : Nat, initValue : T) : [var T] = Prim.Array_init<T>(size, initValue);

  public func generate<T>(size : Nat, generator : Nat -> T) : [var T] {
    todo()
  };

  public func equal<T>(array1 : [var T], array2 : [var T], equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func find<T>(array : [var T], predicate : T -> Bool) : ?T {
    todo()
  };

  public func append<T>(array1 : [var T], array2 : [var T]) : [var T] {
    todo()
  };

  public func sort<T>(array : [var T], compare : (T, T) -> Order.Order) : [var T] {
    todo()
  };

  public func sortInPlace<T>(array : [var T], compare : (T, T) -> Order.Order) : () {
    // Stable merge sort in a bottom-up iterative style. Same algorithm as the sort in Buffer.
    let size = array.size();
    if (size == 0) {
      return
    };
    let scratchSpace = Prim.Array_init<T>(size, array[0]);

    let sizeDec = size - 1 : Nat;
    var currSize = 1; // current size of the subarrays being merged
    // when the current size == size, the array has been merged into a single sorted array
    while (currSize < size) {
      var leftStart = 0; // selects the current left subarray being merged
      while (leftStart < sizeDec) {
        let mid : Nat = if (leftStart + currSize - 1 : Nat < sizeDec) {
          leftStart + currSize - 1
        } else { sizeDec };
        let rightEnd : Nat = if (leftStart + (2 * currSize) - 1 : Nat < sizeDec) {
          leftStart + (2 * currSize) - 1
        } else { sizeDec };

        // Merge subarrays elements[leftStart...mid] and elements[mid+1...rightEnd]
        var left = leftStart;
        var right = mid + 1;
        var nextSorted = leftStart;
        while (left < mid + 1 and right < rightEnd + 1) {
          let leftElement = array[left];
          let rightElement = array[right];
          switch (compare(leftElement, rightElement)) {
            case (#less or #equal) {
              scratchSpace[nextSorted] := leftElement;
              left += 1
            };
            case (#greater) {
              scratchSpace[nextSorted] := rightElement;
              right += 1
            }
          };
          nextSorted += 1
        };
        while (left < mid + 1) {
          scratchSpace[nextSorted] := array[left];
          nextSorted += 1;
          left += 1
        };
        while (right < rightEnd + 1) {
          scratchSpace[nextSorted] := array[right];
          nextSorted += 1;
          right += 1
        };

        // Copy over merged elements
        var i = leftStart;
        while (i < rightEnd + 1) {
          array[i] := scratchSpace[i];
          i += 1
        };

        leftStart += 2 * currSize
      };
      currSize *= 2
    }
  };

  public func reverse<T>(array : [var T]) : [var T] {
    todo()
  };

  public func reverseInPlace<T>(array : [var T]) : () {
    todo()
  };

  public func forEach<T>(array : [var T], f : T -> ()) {
    todo()
  };

  public func map<T, Y>(array : [var T], f : T -> Y) : [var Y] {
    todo()
  };

  public func filter<T>(array : [var T], f : T -> Bool) : [var T] {
    todo()
  };

  public func filterMap<T, Y>(array : [var T], f : T -> ?Y) : [var Y] {
    todo()
  };

  public func mapResult<T, Y, E>(array : [var T], f : T -> Result.Result<Y, E>) : Result.Result<[var Y], E> {
    todo()
  };

  public func mapEntries<T, Y>(array : [var T], f : (T, Nat) -> Y) : [var Y] {
    todo()
  };

  public func flatMap<T, R>(array : [var T], k : T -> [var R]) : [var R] {
    todo()
  };

  public func foldLeft<T, A>(array : [var T], base : A, combine : (A, T) -> A) : A {
    todo()
  };

  public func foldRight<T, A>(array : [var T], base : A, combine : (T, A) -> A) : A {
    todo()
  };

  public func flatten<T>(arrays : Iter.Iter<[var T]>) : [var T] {
    todo()
  };

  public func singleton<T>(element : T) : [var T] = [var element];

  public func size<T>(array : [var T]) : Nat = array.size();

  public func isEmpty<T>(array : [var T]) : Bool = array.size() == 0;

  public func fromIter<T>(iter : Iter.Iter<T>) : [var T] {
    todo()
  };

  public func keys<T>(array : [var T]) : Iter.Iter<Nat> = array.keys();

  public func values<T>(array : [var T]) : Iter.Iter<T> = array.vals();

  public func all<T>(array : [var T], predicate : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(array : [var T], predicate : T -> Bool) : Bool {
    todo()
  };

  public func subArray<T>(array : [var T], start : Nat, length : Nat) : [var T] {
    todo()
  };

  public func indexOf<T>(element : T, array : [var T], equal : (T, T) -> Bool) : ?Nat = nextIndexOf<T>(element, array, 0, equal);

  public func nextIndexOf<T>(element : T, array : [var T], fromInclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func lastIndexOf<T>(element : T, array : [var T], equal : (T, T) -> Bool) : ?Nat = prevIndexOf<T>(element, array, array.size(), equal);

  public func prevIndexOf<T>(element : T, array : [var T], fromExclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func slice<T>(array : [var T], fromInclusive : Int, toExclusive : Int) : Iter.Iter<T> {
    todo()
  };

  public func toText<T>(array : [var T], f : T -> Text) : Text {
    todo()
  };

  public func compare<T>(array1 : [var T], array2 : [var T], compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

}
