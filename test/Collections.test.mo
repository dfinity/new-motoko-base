import Iter "../src/Iter";

// Primitive collections
import Array "../src/Array";
import Blob "../src/Blob";
import Text "../src/Text";

// Imperative collections
import Queue "../src/Queue";
import Set "../src/Set";
import Stack "../src/Stack";
import Vec "../src/Vec";

// Purely functional collections
import PureStack "../src/pure/Stack";
import PureQueue "../src/pure/Queue";

type T = Any;

// let _ = Array : SeqLike<[T]>;
let _ = Queue : SeqLike<Queue.Queue<T>>;
let _ = Set : SeqLike<Set.Set<T>>;
let _ = Stack : SeqLike<Stack.Stack<T>>;
let _ = Vec : SeqLike<Vec.Vec<T>>;

let _ = PureStack : PureSeqLike<PureStack.Stack<T>>;
let _ = PureQueue : PureSeqLike<PureQueue.Queue<T>>;

type SeqLike<C> = module {
  new : Any; // <T>() -> C;
  // toPure : Any; // (Any) -> C;
  // fromPure : Any; // (C) -> Any;
  clone : Any; // (C) -> C;
  isEmpty : Any; // (C) -> Bool;
  size : Any; // (C) -> Nat;
  contains : Any; // <T>(C, T) -> Bool;
  // equal : (C, C) -> Bool;
  toIter : Any; // <T>(C) -> Iter.Iter<T>;
  // fromIter : (Iter.Iter<T>) -> C;
  // forEach : <T>(C, T -> ()) -> ();
  // extend : <T>(C, C) -> ();
  // concat : <T>([C]) -> C;
  toText : Any; // <T>(C, T -> Text) -> Text
};
type PureSeqLike<C> = module {
  new : <T>() -> C;
  isEmpty : (C) -> Bool;
  size : (C) -> Nat;
  contains : Any; // <T>(C, T) -> Bool;
  // equal : (C, C) -> Bool;
  toIter : Any; // <T>(C) -> Iter.Iter<T>;
  // fromIter : (Iter.Iter<T>) -> C;
  // forEach : <T>(C, T -> ()) -> ();
  // concat : <T>([C]) -> C;
  // extend : <T>(C, C) -> C;
  toText : Any // <T>(C, T -> Text) -> Text
}
