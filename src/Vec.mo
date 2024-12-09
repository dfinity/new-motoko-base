/// Original: `vector` Mops package?

import Order "Order";
import { nyi = todo } "Debug";

module {
  type Vec<T> = (); // Placeholder

  public func contains<T>(vec : Vec<T>, item : T, compare : (T, T) -> Order.Order) : Bool = todo();

  public func get<T>(vec : Vec<T>, index : Nat, compare : (T, T) -> Order.Order) : T = todo();

  // ...
}
