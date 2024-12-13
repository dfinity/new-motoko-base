/// Original: `vector` Mops package?

import Order "Order";
import Result "Result";
import { nyi = todo } "Debug";

module {
  type Vec<T> = (); // Placeholder

  public func new<T>() : Vec<T> {
    todo()
  };

  public func clone<T>(vec : Vec<T>) : Vec<T> {
    todo()
  };

  public func isEmpty<T>(vec : Vec<T>) : Bool {
    todo()
  };

  public func contains<T>(vec : Vec<T>, element : T, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func max<T>(vec : Vec<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(vec : Vec<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func equal<T>(vec1 : Vec<T>, vec2 : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func compare<T>(vec1 : Vec<T>, vec2 : Vec<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  public func toText<T>(vec : Vec<T>, toText : T -> Text) : Text {
    todo()
  };

  public func hash<T>(vec : Vec<T>, hash : T -> Nat32) : Nat32 {
    todo()
  };

  public func indexOf<T>(element : T, vec : Vec<T>, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func lastIndexOf<T>(element : T, vec : Vec<T>, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func indexOfVec<T>(subVec : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : ?Nat {
    todo()
  };

  public func binarySearch<T>(element : T, vec : Vec<T>, compare : (T, T) -> Order.Order) : ?Nat {
    todo()
  };

  public func subVec<T>(vec : Vec<T>, start : Nat, length : Nat) : Vec<T> {
    todo()
  };

  public func isSubVecOf<T>(subVec : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func isStrictSubVecOf<T>(subVec : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func prefix<T>(vec : Vec<T>, length : Nat) : Vec<T> {
    todo()
  };

  public func isPrefixOf<T>(prefix : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func isStrictPrefixOf<T>(prefix : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func suffix<T>(vec : Vec<T>, length : Nat) : Vec<T> {
    todo()
  };

  public func isSuffixOf<T>(suffix : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func isStrictSuffixOf<T>(suffix : Vec<T>, vec : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func forAll<T>(vec : Vec<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func forSome<T>(vec : Vec<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func forNone<T>(vec : Vec<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func toArray<T>(vec : Vec<T>) : [T] {
    todo()
  };

  public func toVarArray<T>(vec : Vec<T>) : [var T] {
    todo()
  };

  public func fromArray<T>(array : [T]) : Vec<T> {
    todo()
  };

  public func fromVarArray<T>(array : [var T]) : Vec<T> {
    todo()
  };

  public func fromIter<T>(iter : { next : () -> ?T }) : Vec<T> {
    todo()
  };

  public func trimToSize<T>(vec : Vec<T>) {
    todo()
  };

  public func map<T, Y>(vec : Vec<T>, f : T -> Y) : Vec<Y> {
    todo()
  };

  public func iterate<T>(vec : Vec<T>, f : T -> ()) {
    todo()
  };

  public func mapEntries<T, Y>(vec : Vec<T>, f : (Nat, T) -> Y) : Vec<Y> {
    todo()
  };

  public func mapFilter<T, Y>(vec : Vec<T>, f : T -> ?Y) : Vec<Y> {
    todo()
  };

  public func mapResult<T, Y, E>(vec : Vec<T>, f : T -> Result.Result<Y, E>) : Result.Result<Vec<Y>, E> {
    todo()
  };

  public func chain<T, Y>(vec : Vec<T>, k : T -> Vec<Y>) : Vec<Y> {
    todo()
  };

  public func foldLeft<A, T>(vec : Vec<T>, base : A, combine : (A, T) -> A) : A {
    todo()
  };

  public func foldRight<T, A>(vec : Vec<T>, base : A, combine : (T, A) -> A) : A {
    todo()
  };

  public func first<T>(vec : Vec<T>) : T = todo();

  public func last<T>(vec : Vec<T>) : T = todo();

  public func make<T>(element : T) : Vec<T> {
    todo()
  };

  public func reverse<T>(vec : Vec<T>) {
    todo()
  };

  public func merge<T>(vec1 : Vec<T>, vec2 : Vec<T>, compare : (T, T) -> Order.Order) : Vec<T> {
    todo()
  };

  public func removeDuplicates<T>(vec : Vec<T>, compare : (T, T) -> Order.Order) {
    todo()
  };

  public func partition<T>(vec : Vec<T>, predicate : T -> Bool) : (Vec<T>, Vec<T>) {
    todo()
  };

  public func split<T>(vec : Vec<T>, index : Nat) : (Vec<T>, Vec<T>) {
    todo()
  };

  public func chunk<T>(vec : Vec<T>, size : Nat) : Vec<Vec<T>> {
    todo()
  };

  public func groupBy<T>(vec : Vec<T>, equal : (T, T) -> Bool) : Vec<Vec<T>> {
    todo()
  };

  public func flatten<T>(vec : Vec<Vec<T>>) : Vec<T> {
    todo()
  };

  public func zip<T, Y>(vec1 : Vec<T>, vec2 : Vec<Y>) : Vec<(T, Y)> {
    todo()
  };

  public func zipWith<T, Y, Z>(vec1 : Vec<T>, vec2 : Vec<Y>, zip : (T, Y) -> Z) : Vec<Z> {
    todo()
  };

  public func takeWhile<T>(vec : Vec<T>, predicate : T -> Bool) : Vec<T> {
    todo()
  };

  public func dropWhile<T>(vec : Vec<T>, predicate : T -> Bool) : Vec<T> {
    todo()
  };

}
