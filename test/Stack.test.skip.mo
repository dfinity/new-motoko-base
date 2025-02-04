import Stack "../src/Stack";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let stack = Stack.empty<Nat>();
Stack.push(stack, 1);
Stack.push(stack, 2);

let suite = Suite.suite(
  "Stack",
  [
    Suite.test(
      "init isEmpty",
      Stack.isEmpty(Stack.empty<Nat>()),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "isEmpty false",
      Stack.isEmpty(stack),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "peek",
      Stack.peek(stack),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "peek empty",
      Stack.peek(Stack.empty<Nat>()),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "pop empty",
      Stack.pop(Stack.empty<Nat>()),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "pop",
      Stack.pop(stack),
      M.equals(T.optional(T.natTestable, ?2 : ?Nat))
    ),
    Suite.test(
      "pop 2",
      Stack.pop(stack),
      M.equals(T.optional(T.natTestable, ?1 : ?Nat))
    ),
    Suite.test(
      "pop until empty",
      Stack.pop(stack),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "pop until empty isEmpty",
      Stack.isEmpty(stack),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "push",
      do {
        Stack.push(stack, 3);
        Stack.peek(stack)
      },
      M.equals(T.optional(T.natTestable, ?3 : ?Nat))
    ),
    Suite.test(
      "push isEmpty",
      Stack.isEmpty(stack),
      M.equals(T.bool(false))
    )
  ]
);

Suite.run(suite)
