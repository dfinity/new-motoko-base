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

let _ = Array : SeqLike<[Any]>;
let _ = Queue : SeqLike<Queue.Queue<Any>>;
let _ = Set : SeqLike<Set.Set<Any>>;
let _ = Stack : SeqLike<Stack.Stack<Any>>;
let _ = Vec : SeqLike<Vec.Vec<Any>>;

let _ = PureStack : PureSeqLike<PureStack.PureStack<Any>>;
let _ = PureQueue : PureSeqLike<PureQueue.PureQueue<Any>>;

type BaseSeqLike<C> = module {
  clone : (C) -> C;
  empty : <T>() -> C;
  isEmpty : <T>(C) -> Bool;
  size : <T>(C) -> Nat;
  forEach : <T>(C, T -> ()) -> ();
  concat : <T>(C, C) -> C;
  concatAll : <T>([C]) -> C;
  toText : <T>(C, T -> Text) -> Text
};
type PureSeqLike<C> = BaseSeqLike;
type SeqLike<C> = BaseSeqLike
