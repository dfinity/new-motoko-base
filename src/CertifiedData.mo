/// Certified data

import Prim "mo:⛔";

module {

  public let set : (data : Blob) -> () = Prim.setCertifiedData;

  public let getCertificate : () -> ?Blob = Prim.getCertificate;

}
