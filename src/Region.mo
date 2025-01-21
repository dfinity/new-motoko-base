/// Byte-level access to isolated, (virtual) stable memory _regions_

import Prim "mo:⛔";

module {

  public type Region = Prim.Types.Region;

  public let new : () -> Region = Prim.regionNew;

  public let id : Region -> Nat = Prim.regionId;

  public let size : (region : Region) -> (pages : Nat64) = Prim.regionSize;

  public let grow : (region : Region, newPages : Nat64) -> (oldPages : Nat64) = Prim.regionGrow;

  public let loadNat8 : (region : Region, offset : Nat64) -> Nat8 = Prim.regionLoadNat8;

  public let storeNat8 : (region : Region, offset : Nat64, value : Nat8) -> () = Prim.regionStoreNat8;

  public let loadNat16 : (region : Region, offset : Nat64) -> Nat16 = Prim.regionLoadNat16;

  public let storeNat16 : (region : Region, offset : Nat64, value : Nat16) -> () = Prim.regionStoreNat16;

  public let loadNat32 : (region : Region, offset : Nat64) -> Nat32 = Prim.regionLoadNat32;

  public let storeNat32 : (region : Region, offset : Nat64, value : Nat32) -> () = Prim.regionStoreNat32;

  public let loadNat64 : (region : Region, offset : Nat64) -> Nat64 = Prim.regionLoadNat64;

  public let storeNat64 : (region : Region, offset : Nat64, value : Nat64) -> () = Prim.regionStoreNat64;

  public let loadInt8 : (region : Region, offset : Nat64) -> Int8 = Prim.regionLoadInt8;

  public let storeInt8 : (region : Region, offset : Nat64, value : Int8) -> () = Prim.regionStoreInt8;

  public let loadInt16 : (region : Region, offset : Nat64) -> Int16 = Prim.regionLoadInt16;

  public let storeInt16 : (region : Region, offset : Nat64, value : Int16) -> () = Prim.regionStoreInt16;

  public let loadInt32 : (region : Region, offset : Nat64) -> Int32 = Prim.regionLoadInt32;

  public let storeInt32 : (region : Region, offset : Nat64, value : Int32) -> () = Prim.regionStoreInt32;

  public let loadInt64 : (region : Region, offset : Nat64) -> Int64 = Prim.regionLoadInt64;

  public let storeInt64 : (region : Region, offset : Nat64, value : Int64) -> () = Prim.regionStoreInt64;

  public let loadFloat : (region : Region, offset : Nat64) -> Float = Prim.regionLoadFloat;

  public let storeFloat : (region: Region, offset : Nat64, value : Float) -> () = Prim.regionStoreFloat;

  public let loadBlob : (region : Region, offset : Nat64, size : Nat) -> Blob = Prim.regionLoadBlob;

  public let storeBlob : (region : Region, offset : Nat64, value : Blob) -> () = Prim.regionStoreBlob;

}
