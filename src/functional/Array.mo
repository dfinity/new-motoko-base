/// Provides extended utility functions on Arrays.
///
/// Note the difference between mutable and non-mutable arrays below.
///
/// WARNING: If you are looking for a list that can grow and shrink in size,
/// it is recommended you use either the Buffer class or the List class for
/// those purposes. Arrays must be created with a fixed size.
///
/// Import from the base library to use this module.
/// ```motoko name=import
/// import Array "mo:base/Array";
/// ```

import Iter "../IterType";
import Order "../Order";
import Result "../Result";
import Prim "mo:⛔";
import { nyi = todo } "../Debug";

module {
  public func init<X>(size : Nat, initValue : X) : [var X] = Prim.Array_init<X>(size, initValue);

  public func tabulate<X>(size : Nat, generator : Nat -> X) : [X] = Prim.Array_tabulate<X>(size, generator);

  public func tabulateVar<X>(size : Nat, generator : Nat -> X) : [var X] {
    todo()
  };

  public func freeze<X>(varArray : [var X]) : [X] = Prim.Array_tabulate<X>(varArray.size(), func i = varArray[i]);

  public func thaw<A>(array : [A]) : [var A] {
    todo()
  };

  public func equal<X>(array1 : [X], array2 : [X], equal : (X, X) -> Bool) : Bool {
    todo()
  };

  public func find<X>(array : [X], predicate : X -> Bool) : ?X {
    todo()
  };

  public func append<X>(array1 : [X], array2 : [X]) : [X] {
    todo()
  };

  public func sort<X>(array : [X], compare : (X, X) -> Order.Order) : [X] {
    todo()
  };

  public func sortInPlace<X>(array : [var X], compare : (X, X) -> Order.Order) {
    todo()
  };

  public func reverse<X>(array : [X]) : [X] {
    todo()
  };

  public func map<X, Y>(array : [X], f : X -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i]));

  public func filter<X>(array : [X], predicate : X -> Bool) : [X] {
    todo()
  };

  public func mapEntries<X, Y>(array : [X], f : (X, Nat) -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i], i));

  public func mapFilter<X, Y>(array : [X], f : X -> ?Y) : [Y] {
    todo()
  };

  public func mapResult<X, Y, E>(array : [X], f : X -> Result.Result<Y, E>) : Result.Result<[Y], E> {
    todo()
  };

  public func chain<X, Y>(array : [X], k : X -> [Y]) : [Y] {
    todo()
  };

  public func foldLeft<X, A>(array : [X], base : A, combine : (A, X) -> A) : A {
    todo()
  };

  public func foldRight<X, A>(array : [X], base : A, combine : (X, A) -> A) : A {
    todo()
  };

  public func flatten<X>(arrays : [[X]]) : [X] {
    todo()
  };

  public func singleton<X>(element : X) : [X] = [element];

  public func vals<X>(array : [X]) : Iter.Iter<X> = array.vals();

  public func keys<X>(array : [X]) : Iter.Iter<Nat> = array.keys();

  public func size<X>(array : [X]) : Nat = array.size();

  public func subArray<X>(array : [X], start : Nat, length : Nat) : [X] {
    todo()
  };

  public func indexOf<X>(element : X, array : [X], equal : (X, X) -> Bool) : ?Nat = nextIndexOf<X>(element, array, 0, equal);

  public func nextIndexOf<X>(element : X, array : [X], fromInclusive : Nat, equal : (X, X) -> Bool) : ?Nat {
    todo()
  };

  public func lastIndexOf<X>(element : X, array : [X], equal : (X, X) -> Bool) : ?Nat = prevIndexOf<X>(element, array, array.size(), equal);

  public func prevIndexOf<T>(element : T, array : [T], fromExclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func slice<X>(array : [X], fromInclusive : Nat, toExclusive : Nat) : Iter.Iter<X> = object {
    todo()
  };

  public func take<T>(array : [T], length : Int) : [T] {
    todo()
  }
}
