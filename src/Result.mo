/// Error handling with the Result type

import Order "Order";
import { todo } "Debug";

module {

  public type Result<R, E> = {
    #ok : R;
    #err : E
  };

  public func equal<R, E>(
    eqOk : (R, R) -> Bool,
    eqErr : (E, E) -> Bool,
    r1 : Result<R, E>,
    r2 : Result<R, E>
  ) : Bool {
    todo()
  };

  public func compare<R, E>(
    compareOk : (R, R) -> Order.Order,
    compareErr : (E, E) -> Order.Order,
    r1 : Result<R, E>,
    r2 : Result<R, E>
  ) : Order.Order {
    todo()
  };

  public func chain<R1, R2, Error>(
    result : Result<R1, Error>,
    y : R1 -> Result<R2, Error>
  ) : Result<R2, Error> {
    todo()
  };

  public func flatten<R, E>(
    result : Result<Result<R, E>, E>
  ) : Result<R, E> {
    todo()
  };

  public func mapOk<R1, R2, E>(
    result : Result<R1, E>,
    f : R1 -> R2
  ) : Result<R2, E> {
    todo()
  };

  public func mapErr<R, E1, E2>(
    result : Result<R, E1>,
    f : E1 -> E2
  ) : Result<R, E2> {
    todo()
  };

  public func fromOption<R, E>(ok : ?R, err : E) : Result<R, E> {
    todo()
  };

  public func toOption<R, E>(result : Result<R, E>) : ?R {
    todo()
  };

  public func forEach<R, E>(result : Result<R, E>, f : R -> ()) {
    todo()
  };

  public func assertOk(result : Result<Any, Any>) {
    todo()
  };

  public func assertErr(result : Result<Any, Any>) {
    todo()
  };

  public func fromUpper<R, E>(
    result : { #Ok : R; #Err : E }
  ) : Result<R, E> {
    todo()
  };

  public func toUpper<R, E>(
    result : Result<R, E>
  ) : { #Ok : R; #Err : E } {
    todo()
  };

}
