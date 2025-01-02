/// Utilities for `Blob` (immutable sequence of bytes)

import Prim "mo:⛔";

module {

  public type Blob = Prim.Types.Blob;
  
  public func fromArray(bytes : [Nat8]) : Blob = Prim.arrayToBlob bytes;

  public func fromVarArray(bytes : [var Nat8]) : Blob = Prim.arrayMutToBlob bytes;

  public func toArray(blob : Blob) : [Nat8] = Prim.blobToArray blob;

  public func toVarArray(blob : Blob) : [var Nat8] = Prim.blobToArrayMut blob;

  public func hash(blob : Blob) : Nat32 = Prim.hashBlob blob;

  public func compare(b1 : Blob, b2 : Blob) : { #less; #equal; #greater } {
    let c = Prim.blobCompare(b1, b2);
    if (c < 0) #less else if (c == 0) #equal else #greater
  };

  public func equal(blob1 : Blob, blob2 : Blob) : Bool { blob1 == blob2 };

  public func notEqual(blob1 : Blob, blob2 : Blob) : Bool { blob1 != blob2 };

  public func less(blob1 : Blob, blob2 : Blob) : Bool { blob1 < blob2 };

  public func lessOrEqual(blob1 : Blob, blob2 : Blob) : Bool { blob1 <= blob2 };

  public func greater(blob1 : Blob, blob2 : Blob) : Bool { blob1 > blob2 };

  public func greaterOrEqual(blob1 : Blob, blob2 : Blob) : Bool { blob1 >= blob2 };

}
