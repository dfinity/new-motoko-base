/// Original: `vector` Mops package?

import Order "Order";
import { nyi = todo } "Debug";

module {
  type Ops<T> = { compare : (T, T) -> Order.Order };

  type State<T> = (); // Placeholder

  public class List<T>(ops : Ops<T>, state : State<T>) {
    public func contains(item : T) : Bool = todo();

    public func get(index : Nat) : T = todo()

    // ...
  };

  public func contains<T>(ops : Ops<T>, vec : List<T>, item : T) : Bool = todo();

  public func get<T>(ops : Ops<T>, vec : List<T>, index : Nat) : T = todo();

  // ...
}
