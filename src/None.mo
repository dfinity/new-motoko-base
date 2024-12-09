/// Utilities for the `None` type

import Prim "mo:⛔";

module {

  public type None = Prim.Types.None;

  public let impossible : <A> None -> A = func<A>(x : None) : A {
    switch (x) {}
  };

}
