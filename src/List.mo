/// Original: `vector` Mops package?

import Iter "Iter";
import Order "Order";
import Result "Result";
import { todo } "Debug";

module {
  public type List<T> = (); // Placeholder

  public func new<T>() : List<T> {
    todo()
  };

  public func clone<T>(list : List<T>) : List<T> {
    todo()
  };

  public func isEmpty(list : List<Any>) : Bool {
    todo()
  };

  public func size(list : List<Any>) : Bool {
    todo()
  };

  public func contains<T>(list : List<T>, element : T, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func containsAll<T>(list : List<T>, subList : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func equal<T>(list1 : List<T>, list2 : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func compare<T>(list1 : List<T>, list2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  public func push<T>(list : List<T>, item : T) : () {
    todo()
  };

  public func pop<T>(list : List<T>) : ?T {
    todo()
  };

  public func toText<T>(list : List<T>, f : T -> Text) : Text {
    todo()
  };

  public func hash<T>(list : List<T>, hash : T -> Nat32) : Nat32 {
    todo()
  };

  public func indexOf<T>(list : List<T>, element : T, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func lastIndexOf<T>(list : List<T>, element : T, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func indexOfList<T>(list : List<T>, subList : List<T>, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func binarySearch<T>(list : List<T>, element : T, compare : (T, T) -> Order.Order) : ?Nat {
    todo()
  };

  public func subList<T>(list : List<T>, start : Nat, length : Nat) : List<T> {
    todo()
  };

  public func prefix<T>(list : List<T>, length : Nat) : List<T> {
    todo()
  };

  public func isPrefixOf<T>(list : List<T>, prefix : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func isStrictPrefixOf<T>(list : List<T>, prefix : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func suffix<T>(list : List<T>, length : Nat) : List<T> {
    todo()
  };

  public func isSuffixOf<T>(list : List<T>, suffix : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func isStrictSuffixOf<T>(list : List<T>, suffix : List<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func max<T>(list : List<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(list : List<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func all<T>(list : List<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(list : List<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func toArray<T>(list : List<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(list : List<T>) : [var T] {
    todo()
  };

  public func fromArray<T>(array : [T]) : List<T> {
    todo()
  };

  public func fromVarArray<T>(array : [var T]) : List<T> {
    todo()
  };

  public func values<T>(list : List<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromIter<T>(iter : { next : () -> ?T }) : List<T> {
    todo()
  };

  public func trimToSize<T>(list : List<T>) {
    todo()
  };

  public func map<T1, T2>(list : List<T1>, f : T1 -> T2) : List<T2> {
    todo()
  };

  public func flatMap<T1, T2>(list : List<T1>, k : T1 -> Iter.Iter<T2>) : List<T2> {
    todo()
  };

  public func forEach<T>(list : List<T>, f : T -> ()) {
    todo()
  };

  public func filterMap<T1, T2>(list : List<T1>, f : T1 -> ?T2) : List<T2> {
    todo()
  };

  public func mapEntries<T1, T2>(list : List<T1>, f : (Nat, T1) -> T2) : List<T2> {
    todo()
  };

  public func mapResult<T, R, E>(list : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> {
    todo()
  };

  public func foldLeft<A, T>(list : List<T>, base : A, combine : (A, T) -> A) : A {
    todo()
  };

  public func foldRight<T, A>(list : List<T>, base : A, combine : (T, A) -> A) : A {
    todo()
  };

  public func first<T>(list : List<T>) : T = todo();

  public func last<T>(list : List<T>) : T = todo();

  public func singleton<T>(element : T) : List<T> {
    todo()
  };

  public func reverse<T>(list : List<T>) {
    todo()
  };

  public func merge<T>(list1 : List<T>, list2 : List<T>, compare : (T, T) -> Order.Order) : List<T> {
    todo()
  };

  public func distinct<T>(list : List<T>, equal : (T, T) -> Bool) : List<T> {
    todo()
  };

  public func partition<T>(list : List<T>, predicate : T -> Bool) : (List<T>, List<T>) {
    todo()
  };

  public func split<T>(list : List<T>, index : Nat) : (List<T>, List<T>) {
    todo()
  };

  public func chunk<T>(list : List<T>, size : Nat) : List<List<T>> {
    todo()
  };

  public func flatten<T>(lists : Iter.Iter<List<T>>) : List<T> {
    todo()
  };

  public func zip<T1, T2>(list1 : List<T1>, list2 : List<T2>) : List<(T1, T2)> {
    todo()
  };

  public func zipWith<T1, T2, Z>(list1 : List<T1>, list2 : List<T2>, zip : (T1, T2) -> Z) : List<Z> {
    todo()
  };

  public func filter<T>(list : List<T>, predicate : T -> Bool) : List<T> {
    todo()
  };

}
