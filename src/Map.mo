/// Original: `OrderedMap.mo`

import Order "Order";
import { nyi = todo } "Debug";

module {
  type Ops<K> = { compare : (K, K) -> Order.Order };

  type State<K, V> = (); // Placeholder

  public class Map<K, V>(ops : Ops<K>, state : State<K, V>) {
    public func containsKey<K, V>(map : Map<K, V>, key : K) : Bool = todo();

    public func get<K, V>(key : K) : ?V = todo();

    public func put<K, V>(key : K, value : V) : Bool = todo();

    public func remove<K, V>(key : K) : ?V = todo()

    // ...
  };

  public func containsKey<K, V>(map : Map<K, V>, key : K) : Bool = todo();

  public func get<K, V>(map : Map<K, V>, key : K) : ?V = todo();

  public func put<K, V>(map : Map<K, V>, key : K, value : V) : Bool = todo();

  public func remove<K, V>(map : Map<K, V>, key : K) : ?V = todo();

  // ...
}
