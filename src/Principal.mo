/// Module for interacting with Principals (users and canisters)

import Prim "mo:⛔";
import Blob "Blob";
import Hash "Hash";
import Order "Order";
import Array "functional/Array";
import Text "Text";
import { nyi = todo } "Debug";

module {

  public type Principal = Prim.Types.Principal;

  public func fromActor(a : actor {}) : Principal = Prim.principalOfActor a;

  public func toLedgerAccount(principal : Principal, subAccount : ?Blob) : Blob {
    todo()
  };

  public func toBlob(p : Principal) : Blob = Prim.blobOfPrincipal p;

  public func fromBlob(b : Blob) : Principal = Prim.principalOfBlob b;

  public func toText(p : Principal) : Text = debug_show (p);

  public func fromText(t : Text) : Principal = fromActor(actor (t));

  private let anonymous : Blob = "\04";

  public func isAnonymous(p : Principal) : Bool = Prim.blobOfPrincipal p == anonymousPrincipal;

  public func isController(p : Principal) : Bool = Prim.isController p;

  public func hash(principal : Principal) : Hash.Hash = Blob.hash(Prim.blobOfPrincipal(principal));

  public func compare(principal1 : Principal, principal2 : Principal) : Order.Order {
    todo()
  };

  public func equal(principal1 : Principal, principal2 : Principal) : Bool {
    principal1 == principal2
  };

}
