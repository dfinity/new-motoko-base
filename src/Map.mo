/// Original: `OrderedMap.mo`

import Immutable "immutable/Map";
import Iter "IterType";
import Order "Order";
import { todo } "Debug";

module {

  type Map<K, V> = { var immutable : Immutable.Map<K, V> };

  public func freeze<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order) : Immutable.Map<K, V> = map.immutable;

  public func thaw<K, V>(map : Immutable.Map<K, V>, compare : (K, K) -> Order.Order) : Map<K, V> = {
    var immutable = map
  };

  public func empty<K, V>() : Map<K, V> {
    todo()
  };

  public func isEmpty<K, V>(map : Map<K, V>) : Bool {
    todo()
  };

  public func clear<K, V>(map : Map<K,  V>) {
    todo()
  };

  public func clone<K, V>(map : Map<K, V>) : Map<K, V> = { var immutable = map.immutable };

  public func singleton<K, V>(key : K, value : V) : Map<K, V> {
    todo()
  };

  public func size(map : Map<Any, Any>) : Nat {
    todo()
  };

  public func equal<K, V>(map1 : Map<K, V>, map2 : Map<K, V>) : Bool {
    todo()
  };

  public func containsKey<K>(map : Map<K, Any>, compare : (K, K) -> Order.Order, key : K) : Bool {
    todo()
  };

  public func get<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K) : ?V {
    todo()
  };

  public func add<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K, value : V) : () {
    todo()
  };

  public func put<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K, value : V) : ?V {
    todo()
  };

  public func replaceIfExists<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K, value : V) : ?V {
    todo()
  };

  public func delete<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K) : () {
    todo()
  };

  public func maxEntry<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order) : ?(K, V) {
    todo()
  };

  public func minEntry<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order) : ?(K, V) {
    todo()
  };

  public func entries<K, V>(map : Map<K, V>) : Iter.Iter<(K, V)> {
    todo()
  };

  public func reverseEntries<K, V>(map : Map<K, V>) : Iter.Iter<(K, V)> {
    todo()
  };

  public func keys<K>(map : Map<K, Any>) : Iter.Iter<K> {
    todo()
  };

  public func values<V>(map : Map<Any, V>) : Iter.Iter<V> {
    todo()
  };

  public func fromIter<K, V>(iter : Iter.Iter<(K, V)>, compare : (K, K) -> Order.Order) : Map<K, V> {
    todo()
  };

  public func forEach<K, V>(map : Map<K, V>, f : (K, V) -> ()) {
    todo()
  };

  public func filter<K, V>(map : Map<K, V>, f : (K, V) -> Bool) : Map<K, V> {
    todo()
  };

  public func map<K, V1, V2>(map : Map<K, V1>, f : (K, V1) -> V2) : Map<K, V2> {
    todo()
  };

  public func foldLeft<K, V, A>(
    map : Map<K, V>,
    base : A,
    combine : (A, K, V) -> A
  ) : A {
    todo()
  };

  public func foldRight<K, V, A>(
    map : Map<K, V>,
    base : A,
    combine : (K, V, A) -> A
  ) : A {
    todo()
  };

  public func all<K, V>(map : Map<K, V>, pred : (K, V) -> Bool) : Bool {
    todo()
  };

  public func any<K, V>(map : Map<K, V>, pred : (K, V) -> Bool) : Bool {
    todo()
  };

  public func filterMap<K, V1, V2>(map : Map<K, V1>, f : (K, V1) -> ?V2) : Map<K, V2> {
    todo()
  };

  public func assertValid<K>(map : Map<K, Any>, compare : (K, K) -> Order.Order) : () {
    todo()
  };

  public func toText<K, V>(map : Map<K, V>, kf : K -> Text, vf : V -> Text) : Text {
    todo()
  };

  public func compare<K, V>(map1 : Map<K, V>, map2 : Map<K, V>, compareKey : (K, K) -> Order.Order, compareValue : (V, V) -> Order.Order) : Order.Order {
    todo()
  };

}
