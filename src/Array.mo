import Iter "IterType";
import Order "Order";
import Result "Result";
import Prim "mo:⛔";
import { todo } "Debug";

module {
  
  public func new<T>() : [T] = [];

  public func repeat<T>(size : Nat, initValue : T) : [var T] = Prim.Array_init<T>(size, initValue);

  public func generate<T>(size : Nat, generator : Nat -> T) : [T] = Prim.Array_tabulate<T>(size, generator);

  public func generateVar<T>(size : Nat, generator : Nat -> T) : [var T] {
    todo()
  };

  public func fromVarArray<T>(varArray : [var T]) : [T] = Prim.Array_tabulate<T>(varArray.size(), func i = varArray[i]);

  public func toVarArray<T>(array : [T]) : [var T] {
    todo()
  };

  public func equal<T>(array1 : [T], array2 : [T], equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func find<T>(array : [T], predicate : T -> Bool) : ?T {
    todo()
  };

  public func append<T>(array1 : [T], array2 : [T]) : [T] {
    todo()
  };

  public func sort<T>(array : [T], compare : (T, T) -> Order.Order) : [T] {
    todo()
  };

  public func sortInPlace<T>(array : [var T], compare : (T, T) -> Order.Order) : () {
    todo()
  };

  public func reverse<T>(array : [T]) : [T] {
    todo()
  };

  public func reverseInPlace<T>(array : [var T]) : () {
    todo()
  };

  public func map<T, Y>(array : [T], f : T -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i]));

  public func filter<T>(array : [T], f : T -> Bool) : [T] {
    todo()
  };

  public func filterMap<T, Y>(array : [T], f : T -> ?Y) : [Y] {
    todo()
  };

  public func mapResult<T, Y, E>(array : [T], f : T -> Result.Result<Y, E>) : Result.Result<[Y], E> {
    todo()
  };

  public func mapEntries<T, Y>(array : [T], f : (T, Nat) -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i], i));

  public func chain<T, Y>(array : [T], k : T -> [Y]) : [Y] {
    todo()
  };

  public func foldLeft<T, A>(array : [T], base : A, combine : (A, T) -> A) : A {
    todo()
  };

  public func foldRight<T, A>(array : [T], base : A, combine : (T, A) -> A) : A {
    todo()
  };

  public func flatten<T>(arrays : Iter.Iter<[T]>) : [T] {
    todo()
  };

  public func singleton<T>(element : T) : [T] = [element];

  public func fromIter<T>(iter : Iter.Iter<T>) : [T] {
    todo()
  };

  public func keys<T>(array : [T]) : Iter.Iter<Nat> = array.keys();

  public func values<T>(array : [T]) : Iter.Iter<T> = array.vals();

  public func size<T>(array : [T]) : Nat = array.size();

  public func subArray<T>(array : [T], start : Nat, length : Nat) : [T] {
    todo()
  };

  public func indexOf<T>(element : T, array : [T], equal : (T, T) -> Bool) : ?Nat = nextIndexOf<T>(element, array, 0, equal);

  public func nextIndexOf<T>(element : T, array : [T], fromInclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func lastIndexOf<T>(element : T, array : [T], equal : (T, T) -> Bool) : ?Nat = prevIndexOf<T>(element, array, array.size(), equal);

  public func prevIndexOf<T>(element : T, array : [T], fromExclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func slice<T>(array : [T], fromInclusive : Nat, toExclusive : Nat) : Iter.Iter<T> {
    todo()
  };

  public func take<T>(array : [T], length : Int) : [T] {
    todo()
  };

}
