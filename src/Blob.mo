/// Module for working with Blobs (immutable sequences of bytes).
///
/// Blobs represent sequences of bytes. They are immutable, iterable, but not indexable and can be empty.
///
/// Byte sequences are also often represented as `[Nat8]`, i.e. an array of bytes, but this representation is currently much less compact than `Blob`, taking 4 physical bytes to represent each logical byte in the sequence.
/// If you would like to manipulate Blobs, it is recommended that you convert
/// Blobs to `[var Nat8]` or `Buffer<Nat8>`, do the manipulation, then convert back.
///
/// Import from the base library to use this module.
/// ```motoko name=import
/// import Blob "mo:base/Blob";
/// ```
///
/// Some built in features not listed in this module:
///
/// * You can create a `Blob` literal from a `Text` literal, provided the context expects an expression of type `Blob`.
/// * `b.size() : Nat` returns the number of bytes in the blob `b`;
/// * `b.values() : Iter.Iter<Nat8>` returns an iterator to enumerate the bytes of the blob `b`.
///
/// For example:
/// ```motoko include=import
/// import Debug "mo:base/Debug";
/// import Nat8 "mo:base/Nat8";
///
/// let blob = "\00\00\00\ff" : Blob; // blob literals, where each byte is delimited by a back-slash and represented in hex
/// let blob2 = "charsもあり" : Blob; // you can also use characters in the literals
/// let numBytes = blob.size(); // => 4 (returns the number of bytes in the Blob)
/// for (byte : Nat8 in blob.values()) { // iterator over the Blob
///   Debug.print(Nat8.toText(byte))
/// }
/// ```

import Types "Types";
import Prim "mo:⛔";

module {

  public type Blob = Prim.Types.Blob;

  /// Returns an empty `Blob` (equivalent to `""`).
  ///
  /// Example:
  /// ```motoko include=import
  /// let emptyBlob = Blob.empty(); // => ""
  /// assert emptyBlob.size() == 0;
  /// ```
  public func empty() : Blob = "";

  /// Returns whether the given `Blob` is empty (has a size of zero).
  ///
  /// ```motoko include=import
  /// let blob1 = "" : Blob;
  /// let blob2 = "\FF\00" : Blob;
  /// assert Blob.isEmpty(blob1);
  /// assert not Blob.isEmpty(blob2);
  /// ```
  public func isEmpty(blob : Blob) : Bool = blob == "";

  /// Returns the number of bytes in the given `Blob`.
  /// This is equivalent to `blob.size()`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob = "\FF\00\AA" : Blob;
  /// assert Blob.size(blob) == 3;
  /// assert blob.size() == 3;
  /// ```
  public func size(blob : Blob) : Nat = blob.size();

  /// Creates a `Blob` from an array of bytes (`[Nat8]`), by copying each element.
  ///
  /// Example:
  /// ```motoko include=import
  /// let bytes : [Nat8] = [0, 255, 0];
  /// let blob = Blob.fromArray(bytes); // => "\00\FF\00"
  /// ```
  public func fromArray(bytes : [Nat8]) : Blob = Prim.arrayToBlob bytes;

  /// Creates a `Blob` from a mutable array of bytes (`[var Nat8]`), by copying each element.
  ///
  /// Example:
  /// ```motoko include=import
  /// let bytes : [var Nat8] = [var 0, 255, 0];
  /// let blob = Blob.fromVarArray(bytes); // => "\00\FF\00"
  /// ```
  public func fromVarArray(bytes : [var Nat8]) : Blob = Prim.arrayMutToBlob bytes;

  /// Converts a `Blob` to an array of bytes (`[Nat8]`), by copying each element.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob = "\00\FF\00" : Blob;
  /// let bytes = Blob.toArray(blob); // => [0, 255, 0]
  /// ```
  public func toArray(blob : Blob) : [Nat8] = Prim.blobToArray blob;

  /// Converts a `Blob` to a mutable array of bytes (`[var Nat8]`), by copying each element.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob = "\00\FF\00" : Blob;
  /// let bytes = Blob.toVarArray(blob); // => [var 0, 255, 0]
  /// ```
  public func toVarArray(blob : Blob) : [var Nat8] = Prim.blobToArrayMut blob;

  /// Returns the (non-cryptographic) hash of `blob`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob = "\00\FF\00" : Blob;
  /// Blob.hash(blob) // => 1_818_567_776
  /// ```
  public func hash(blob : Blob) : Types.Hash = Prim.hashBlob blob;

  /// General purpose comparison function for `Blob` by comparing the value of
  /// the bytes. Returns the `Order` (either `#less`, `#equal`, or `#greater`)
  /// by comparing `blob1` with `blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\00\00\00" : Blob;
  /// let blob2 = "\00\FF\00" : Blob;
  /// Blob.compare(blob1, blob2) // => #less
  /// ```
  public func compare(b1 : Blob, b2 : Blob) : { #less; #equal; #greater } {
    let c = Prim.blobCompare(b1, b2);
    if (c < 0) #less else if (c == 0) #equal else #greater
  };

  /// Equality function for `Blob` types.
  /// This is equivalent to `blob1 == blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\00\FF\00" : Blob;
  /// let blob2 = "\00\FF\00" : Blob;
  /// ignore Blob.equal(blob1, blob2);
  /// blob1 == blob2 // => true
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `==` operator) is so that you can use it as a function value
  /// to pass to a higher order function.
  ///
  /// Example:
  /// ```motoko include=import
  /// import Buffer "mo:base/Buffer";
  ///
  /// let buffer1 = Buffer.Buffer<Blob>(3);
  /// let buffer2 = Buffer.Buffer<Blob>(3);
  /// Buffer.equal(buffer1, buffer2, Blob.equal) // => true
  /// ```
  public func equal(blob1 : Blob, blob2 : Blob) : Bool { blob1 == blob2 };

  /// Inequality function for `Blob` types.
  /// This is equivalent to `blob1 != blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\00\AA\AA" : Blob;
  /// let blob2 = "\00\FF\00" : Blob;
  /// ignore Blob.notEqual(blob1, blob2);
  /// blob1 != blob2 // => true
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `!=` operator) is so that you can use it as a function value
  /// to pass to a higher order function.
  public func notEqual(blob1 : Blob, blob2 : Blob) : Bool { blob1 != blob2 };

  /// "Less than" function for `Blob` types.
  /// This is equivalent to `blob1 < blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\00\AA\AA" : Blob;
  /// let blob2 = "\00\FF\00" : Blob;
  /// ignore Blob.less(blob1, blob2);
  /// blob1 < blob2 // => true
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `<` operator) is so that you can use it as a function value
  /// to pass to a higher order function.
  public func less(blob1 : Blob, blob2 : Blob) : Bool { blob1 < blob2 };

  /// "Less than or equal to" function for `Blob` types.
  /// This is equivalent to `blob1 <= blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\00\AA\AA" : Blob;
  /// let blob2 = "\00\FF\00" : Blob;
  /// ignore Blob.lessOrEqual(blob1, blob2);
  /// blob1 <= blob2 // => true
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `<=` operator) is so that you can use it as a function value
  /// to pass to a higher order function.
  public func lessOrEqual(blob1 : Blob, blob2 : Blob) : Bool { blob1 <= blob2 };

  /// "Greater than" function for `Blob` types.
  /// This is equivalent to `blob1 > blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\BB\AA\AA" : Blob;
  /// let blob2 = "\00\00\00" : Blob;
  /// ignore Blob.greater(blob1, blob2);
  /// blob1 > blob2 // => true
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `>` operator) is so that you can use it as a function value
  /// to pass to a higher order function.
  public func greater(blob1 : Blob, blob2 : Blob) : Bool { blob1 > blob2 };

  /// "Greater than or equal to" function for `Blob` types.
  /// This is equivalent to `blob1 >= blob2`.
  ///
  /// Example:
  /// ```motoko include=import
  /// let blob1 = "\BB\AA\AA" : Blob;
  /// let blob2 = "\00\00\00" : Blob;
  /// ignore Blob.greaterOrEqual(blob1, blob2);
  /// blob1 >= blob2 // => true
  /// ```
  ///
  /// Note: The reason why this function is defined in this library (in addition
  /// to the existing `>=` operator) is so that you can use it as a function value
  /// to pass to a higher order function.
  public func greaterOrEqual(blob1 : Blob, blob2 : Blob) : Bool {
    blob1 >= blob2
  };

}
