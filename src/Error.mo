/// Error values and inspection

import Prim "mo:⛔";

module {
  public type Error = Prim.Types.Error;

  public type ErrorCode = Prim.ErrorCode;

  public let reject : (message : Text) -> Error = Prim.error;

  public let code : (error : Error) -> ErrorCode = Prim.errorCode;

  public let message : (error : Error) -> Text = Prim.errorMessage;
}