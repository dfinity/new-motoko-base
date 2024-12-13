/// Original: `vector` Mops package?

import Order "Order";
import Result "Result";
import { nyi = todo } "Debug";

module {
  public type Vec<T> = (); // Placeholder

  public func new<T>() : Vec<T> {
    todo()
  };

  public func clone<T>(vec : Vec<T>) : Vec<T> {
    todo()
  };

  public func isEmpty(vec : Vec<Any>) : Bool {
    todo()
  };

  public func size(vec : Vec<Any>) : Bool {
    todo()
  };

  public func contains<T>(vec : Vec<T>, element : T, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func equal<T>(vec1 : Vec<T>, vec2 : Vec<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func compare<T>(vec1 : Vec<T>, vec2 : Vec<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  public func toText<T>(vec : Vec<T>, f : T -> Text) : Text {
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

  public func max<T>(vec : Vec<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(vec : Vec<T>, compare : (T, T) -> Order.Order) : ?T {
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

  public func map<T1, T2>(vec : Vec<T1>, f : T1 -> T2) : Vec<T2> {
    todo()
  };

  public func forEach<T>(vec : Vec<T>, f : T -> ()) {
    todo()
  };

  public func filterMap<T1, T2>(vec : Vec<T1>, f : T1 -> ?T2) : Vec<T2> {
    todo()
  };

  public func mapEntries<T1, T2>(vec : Vec<T1>, f : (Nat, T1) -> T2) : Vec<T2> {
    todo()
  };

  public func mapResult<T, R, E>(vec : Vec<T>, f : T -> Result.Result<R, E>) : Result.Result<Vec<R>, E> {
    todo()
  };

  public func chain<T1, T2>(vec : Vec<T1>, k : T1 -> Vec<T2>) : Vec<T2> {
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

  public func dedupe<T>(vec : Vec<T>, compare : (T, T) -> Order.Order) {
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

  public func zip<T1, T2>(vec1 : Vec<T1>, vec2 : Vec<T2>) : Vec<(T1, T2)> {
    todo()
  };

  public func zipWith<T1, T2, Z>(vec1 : Vec<T1>, vec2 : Vec<T2>, zip : (T1, T2) -> Z) : Vec<Z> {
    todo()
  };

  public func takeWhile<T>(vec : Vec<T>, predicate : T -> Bool) : Vec<T> {
    todo()
  };

  public func dropWhile<T>(vec : Vec<T>, predicate : T -> Bool) : Vec<T> {
    todo()
  };

}
