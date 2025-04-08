/// Error handling with the Result type.

import Order "Order";
import Types "Types";

module {

  /// `Result<Ok, Err>` is the type used for returning and propagating errors. It
  /// is a type with the variants, `#ok(Ok)`, representing success and containing
  /// a value, and `#err(Err)`, representing error and containing an error value.
  ///
  /// The simplest way of working with `Result`s is to pattern match on them:
  ///
  /// For example, given a function `createUser(user : User) : Result<Id, String>`
  /// where `String` is an error message we could use it like so:
  /// ```motoko no-repl
  /// switch(createUser(myUser)) {
  ///   case (#ok(id)) { Debug.print("Created new user with id: " # id) };
  ///   case (#err(msg)) { Debug.print("Failed to create user with the error: " # msg) };
  /// }
  /// ```
  public type Result<Ok, Err> = Types.Result<Ok, Err>;

  // Compares two Result's for equality.
  public func equal<Ok, Err>(
    result1 : Result<Ok, Err>,
    result2 : Result<Ok, Err>,
    equalOk : (Ok, Ok) -> Bool,
    equalErr : (Err, Err) -> Bool
  ) : Bool {
    switch (result1, result2) {
      case (#ok(ok1), #ok(ok2)) {
        equalOk(ok1, ok2)
      };
      case (#err(err1), #err(err2)) {
        equalErr(err1, err2)
      };
      case _ { false }
    }
  };

  // Compares two Results. `#ok` is larger than `#err`. This ordering is
  // arbitrary, but it lets you for example use Results as keys in ordered maps.
  public func compare<Ok, Err>(
    result1 : Result<Ok, Err>,
    result2 : Result<Ok, Err>,
    compareOk : (Ok, Ok) -> Order.Order,
    compareErr : (Err, Err) -> Order.Order
  ) : Order.Order {
    switch (result1, result2) {
      case (#ok(ok1), #ok(ok2)) {
        compareOk(ok1, ok2)
      };
      case (#err(err1), #err(err2)) {
        compareErr(err1, err2)
      };
      case (#ok(_), _) { #greater };
      case (#err(_), _) { #less }
    }
  };

  /// Allows sequencing of `Result` values and functions that return
  /// `Result`'s themselves.
  /// ```motoko
  /// import Result "mo:base/Result";
  /// type Result<Ok,Err> = Result.Result<Ok, Err>;
  /// func largerThan10(x : Nat) : Result<Nat, Text> =
  ///   if (x > 10) { #ok(x) } else { #err("Not larger than 10.") };
  ///
  /// func smallerThan20(x : Nat) : Result<Nat, Text> =
  ///   if (x < 20) { #ok(x) } else { #err("Not smaller than 20.") };
  ///
  /// func between10And20(x : Nat) : Result<Nat, Text> =
  ///   Result.chain(largerThan10(x), smallerThan20);
  ///
  /// assert(between10And20(15) == #ok(15));
  /// assert(between10And20(9) == #err("Not larger than 10."));
  /// assert(between10And20(21) == #err("Not smaller than 20."));
  /// ```
  public func chain<Ok1, Ok2, Err>(
    result : Result<Ok1, Err>,
    f : Ok1 -> Result<Ok2, Err>
  ) : Result<Ok2, Err> {
    switch result {
      case (#err(e)) { #err(e) };
      case (#ok(r)) { f(r) }
    }
  };

  /// Flattens a nested Result.
  ///
  /// ```motoko
  /// import Result "mo:base/Result";
  /// assert(Result.flatten<Nat, Text>(#ok(#ok(10))) == #ok(10));
  /// assert(Result.flatten<Nat, Text>(#err("Wrong")) == #err("Wrong"));
  /// assert(Result.flatten<Nat, Text>(#ok(#err("Wrong"))) == #err("Wrong"));
  /// ```
  public func flatten<Ok, Err>(
    result : Result<Result<Ok, Err>, Err>
  ) : Result<Ok, Err> {
    switch result {
      case (#ok(ok)) { ok };
      case (#err(err)) { #err(err) }
    }
  };

  /// Maps the `Ok` type/value, leaving any `Err` type/value unchanged.
  public func mapOk<Ok1, Ok2, Err>(
    result : Result<Ok1, Err>,
    f : Ok1 -> Ok2
  ) : Result<Ok2, Err> {
    switch result {
      case (#err(e)) { #err(e) };
      case (#ok(r)) { #ok(f(r)) }
    }
  };

  /// Maps the `Err` type/value, leaving any `Ok` type/value unchanged.
  public func mapErr<Ok, Err1, Err2>(
    result : Result<Ok, Err1>,
    f : Err1 -> Err2
  ) : Result<Ok, Err2> {
    switch result {
      case (#err(e)) { #err(f(e)) };
      case (#ok(r)) { #ok(r) }
    }
  };

  /// Create a result from an option, including an error value to handle the `null` case.
  /// ```motoko
  /// import Result "mo:base/Result";
  /// assert(Result.fromOption(?42, "err") == #ok(42));
  /// assert(Result.fromOption(null, "err") == #err("err"));
  /// ```
  public func fromOption<Ok, Err>(x : ?Ok, err : Err) : Result<Ok, Err> {
    switch x {
      case (?x) { #ok(x) };
      case null { #err(err) }
    }
  };

  /// Create an option from a result, turning all #err into `null`.
  /// ```motoko
  /// import Result "mo:base/Result";
  /// assert(Result.toOption(#ok(42)) == ?42);
  /// assert(Result.toOption(#err("err")) == null);
  /// ```
  public func toOption<Ok, Err>(result : Result<Ok, Err>) : ?Ok {
    switch result {
      case (#ok(x)) { ?x };
      case (#err(_)) { null }
    }
  };

  /// Applies a function to a successful value and discards the result. Use
  /// `forOk` if you're only interested in the side effect `f` produces.
  ///
  /// ```motoko
  /// import Result "mo:base/Result";
  /// var counter : Nat = 0;
  /// Result.forOk<Nat, Text>(#ok(5), func (x : Nat) { counter += x });
  /// assert(counter == 5);
  /// Result.forOk<Nat, Text>(#err("Error"), func (x : Nat) { counter += x });
  /// assert(counter == 5);
  /// ```
  public func forOk<Ok, Err>(result : Result<Ok, Err>, f : Ok -> ()) {
    switch result {
      case (#ok(ok)) { f(ok) };
      case _ {}
    }
  };

  /// Applies a function to an error value and discards the result. Use
  /// `forErr` if you're only interested in the side effect `f` produces.
  ///
  /// ```motoko
  /// import Result "mo:base/Result";
  /// var counter : Nat = 0;
  /// Result.forErr<Nat, Text>(#err("Error"), func (x : Text) { counter += 1 });
  /// assert(counter == 1);
  /// Result.forErr<Nat, Text>(#ok(5), func (x : Text) { counter += 1 });
  /// assert(counter == 1);
  /// ```
  public func forErr<Ok, Err>(result : Result<Ok, Err>, f : Err -> ()) {
    switch result {
      case (#err(err)) { f(err) };
      case _ {}
    }
  };

  // Whether this Result is an `#ok`
  public func isOk(result : Result<Any, Any>) : Bool {
    switch result {
      case (#ok(_)) { true };
      case (#err(_)) { false }
    }
  };

  // Whether this Result is an `#err`
  public func isErr(result : Result<Any, Any>) : Bool {
    switch result {
      case (#ok(_)) { false };
      case (#err(_)) { true }
    }
  };

  /// Asserts that its argument is an `#ok` result, traps otherwise.
  public func assertOk(result : Result<Any, Any>) {
    switch result {
      case (#err(_)) { assert false };
      case (#ok(_)) {}
    }
  };

  /// Asserts that its argument is an `#err` result, traps otherwise.
  public func assertErr(result : Result<Any, Any>) {
    switch result {
      case (#err(_)) {};
      case (#ok(_)) assert false
    }
  };

  /// Converts an upper cased `#Ok`, `#Err` result type into a lowercased `#ok`, `#err` result type.
  /// On the IC, a common convention is to use `#Ok` and `#Err` as the variants of a result type,
  /// but in Motoko, we use `#ok` and `#err` instead.
  public func fromUpper<Ok, Err>(
    result : { #Ok : Ok; #Err : Err }
  ) : Result<Ok, Err> {
    switch result {
      case (#Ok(ok)) { #ok(ok) };
      case (#Err(err)) { #err(err) }
    }
  };

  /// Converts a lower cased `#ok`, `#err` result type into an upper cased `#Ok`, `#Err` result type.
  /// On the IC, a common convention is to use `#Ok` and `#Err` as the variants of a result type,
  /// but in Motoko, we use `#ok` and `#err` instead.
  public func toUpper<Ok, Err>(
    result : Result<Ok, Err>
  ) : { #Ok : Ok; #Err : Err } {
    switch result {
      case (#ok(ok)) { #Ok(ok) };
      case (#err(err)) { #Err(err) }
    }
  };

}
