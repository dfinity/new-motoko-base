import Prim "mo:⛔";

module {
  public type Blob = Prim.Types.Blob;
  public type Bool = Prim.Types.Bool;
  public type Char = Prim.Types.Char;
  public type Error = Prim.Types.Error;
  public type ErrorCode = Prim.ErrorCode;
  public type Float = Prim.Types.Float;
  public type Int = Prim.Types.Int;
  public type Int8 = Prim.Types.Int8;
  public type Int16 = Prim.Types.Int16;
  public type Int32 = Prim.Types.Int32;
  public type Int64 = Prim.Types.Int64;
  public type Nat = Prim.Types.Nat;
  public type Nat8 = Prim.Types.Nat8;
  public type Nat16 = Prim.Types.Nat16;
  public type Nat32 = Prim.Types.Nat32;
  public type Nat64 = Prim.Types.Nat64;
  public type Principal = Prim.Types.Principal;
  public type Region = Prim.Types.Region;
  public type Text = Prim.Types.Text;

  public type Hash = Nat32;
  public type Iter<T> = { next : () -> ?T };
  public type Order = { #less; #equal; #greater };
  public type Result<T, E> = { #ok : T; #err : E };
  public type Pattern = {
    #char : Char;
    #text : Text;
    #predicate : (Char -> Bool)
  };
  public type Time = Int;
  public type Duration = {
    #days : Nat;
    #hours : Nat;
    #minutes : Nat;
    #seconds : Nat;
    #milliseconds : Nat;
    #nanoseconds : Nat
  };
  public type TimerId = Nat;

  public type List<T> = (); // Placeholder
  public type Queue<T> = { var pure : Pure.Queue<T> };
  public type Set<T> = { var pure : Pure.Set<T> };

  public module Map {
    public type Node<K, V> = {
      #leaf : Leaf<K, V>;
      #internal : Internal<K, V>
    };

    public type Data<K, V> = {
      kvs : [var ?(K, V)];
      var count : Nat
    };

    public type Internal<K, V> = {
      data : Data<K, V>;
      children : [var ?Node<K, V>]
    };

    public type Leaf<K, V> = { // why the extra indirection?
      data : Data<K, V>
    };

    public type Map<K, V> = {
      var root : Node<K, V>;
      var size : Nat
    }
  };
  public type Map<K, V> = Map.Map<K, V>;

  public module Stack {
    public type Node<T> = {
      value : T;
      next : ?Node<T>
    };

    public type Stack<T> = {
      var top : ?Node<T>;
      var size : Nat
    }
  };
  public type Stack<T> = Stack.Stack<T>;

  public module Pure {
    public type List<T> = ?(T, List<T>);
    public type Map<K, V> = (); // Placeholder
    public type Queue<T> = (Stack.Stack<T>, Stack.Stack<T>);
    public type Set<T> = () // Placeholder
  }
}
