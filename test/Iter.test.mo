import Iter "../src/Iter";
import Array "../src/Array";
import Text "../src/Text";
import Stack "../src/Stack";

// Example usages of `Iter.convert()`

assert Iter.convert(Array, Text, ['a', 'b', 'c']) == "abc";
assert Iter.convert(Text, Array, "abc") == ['a', 'b', 'c'];
assert Iter.convert(Array, Stack, [1, 2, 3]) |> Iter.Convert(Stack, Array, _) == [1, 2, 3];
assert Iter.convert(Array, Stack, [1, 2, 3]) == Stack.fromIter(Iter.generate(3, func(i) = i + 1));
