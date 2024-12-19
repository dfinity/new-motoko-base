import Iter "../src/Iter";

// Primitive collections
import Array "../src/Array";
import Blob "../src/Blob";
import Text "../src/Text";

// Imperative collections
import Queue "../src/Queue";
import Set "../src/Set";
import Stack "../src/Stack";
import List "../src/List";

// Purely functional collections
import PureStack "../src/pure/Stack";
import PureQueue "../src/pure/Queue";

type T = Any;

// let _ = Array : SeqLike<[T]>;
let _ = Queue : SeqLike<Queue.Queue<T>>;
let _ = Set : SeqLike<Set.Set<T>>;
let _ = Stack : SeqLike<Stack.Stack<T>>;
let _ = List : SeqLike<List.List<T>>;

let _ = PureStack : SeqLike<PureStack.Stack<T>>;
let _ = PureQueue : SeqLike<PureQueue.Queue<T>>;

type SeqLike<C> = module {
  new : Any; // <T>() -> C;
  // toPure : Any; // (Any) -> C;
  // fromPure : Any; // (C) -> Any;
  clone : Any; // (C) -> C;
  isEmpty : Any; // (C) -> Bool;
  size : Any; // (C) -> Nat;
  contains : Any; // <T>(C, T) -> Bool;
  map : Any;
  filter : Any;
  filterMap : Any;
  flatMap : Any;
  foldLeft : Any;
  foldRight : Any;
  // equal : (C, C) -> Bool;
  values : Any; // <T>(C) -> Iter.Iter<T>;
  fromValues : Any; // (Iter.Iter<T>) -> C;
  forEach : <T>(C, T -> ()) -> ();
  merge : Any;
  flatten : Any;
  // extend : <T>(C, C) -> ();
  concat : Any;
  toText : Any; // <T>(C, T -> Text) -> Text
};
