/// Error handling with the Result type

import Order "Order";
import { nyi = todo } "Debug";

module {

  public type Result<Ok, Err> = {
    #ok : Ok;
    #err : Err
  };

  public func equal<Ok, Err>(
    eqOk : (Ok, Ok) -> Bool,
    eqErr : (Err, Err) -> Bool,
    r1 : Result<Ok, Err>,
    r2 : Result<Ok, Err>
  ) : Bool {
    todo()
  };

  public func compare<Ok, Err>(
    compareOk : (Ok, Ok) -> Order.Order,
    compareErr : (Err, Err) -> Order.Order,
    r1 : Result<Ok, Err>,
    r2 : Result<Ok, Err>
  ) : Order.Order {
    todo()
  };

  public func chain<R1, R2, Error>(
    x : Result<R1, Error>,
    y : R1 -> Result<R2, Error>
  ) : Result<R2, Error> {
    todo()
  };

  public func flatten<Ok, Error>(
    result : Result<Result<Ok, Error>, Error>
  ) : Result<Ok, Error> {
    todo()
  };

  public func mapOk<Ok1, Ok2, Error>(
    x : Result<Ok1, Error>,
    f : Ok1 -> Ok2
  ) : Result<Ok2, Error> {
    todo()
  };

  public func mapErr<Ok, Error1, Error2>(
    x : Result<Ok, Error1>,
    f : Error1 -> Error2
  ) : Result<Ok, Error2> {
    todo()
  };

  public func fromOption<R, E>(x : ?R, err : E) : Result<R, E> {
    todo()
  };

  public func toOption<R, E>(r : Result<R, E>) : ?R {
    todo()
  };

  public func forEach<Ok, Err>(res : Result<Ok, Err>, f : Ok -> ()) {
    todo()
  };

  public func assertOk(r : Result<Any, Any>) {
    todo()
  };

  public func assertErr(r : Result<Any, Any>) {
    todo()
  };

  public func fromUpper<Ok, Err>(
    result : { #Ok : Ok; #Err : Err }
  ) : Result<Ok, Err> {
    todo()
  };

  public func toUpper<Ok, Err>(
    result : Result<Ok, Err>
  ) : { #Ok : Ok; #Err : Err } {
    todo()
  };

}
