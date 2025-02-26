import Char "../src/Char";
import Prim "mo:⛔";

/*
//
// Char.toUpper
//

assert(Char.toUpper('ö') == 'Ö');
assert(Char.toUpper('σ') == 'Σ');
assert(Char.toUpper('💩') == '💩');

//
// Char.toLower
//

assert(Char.toLower('Ö') == 'ö');
assert(Char.toLower('Σ') == 'σ');
assert(Char.toLower('💩') == '💩');
*/

//
// Char.isWhitespace
//

assert (Char.isWhitespace(' '));

assert (not Char.isWhitespace('x'));

// 12288 (U+3000) = ideographic space
assert (Char.isWhitespace(Prim.nat32ToChar(12288)));

assert (Char.isWhitespace('\t'));

// Vertical tab ('\v')
assert (Char.isWhitespace(Prim.nat32ToChar(0x0B)));

// Form feed ('\f')
assert (Char.isWhitespace(Prim.nat32ToChar(0x0C)));

assert (Char.isWhitespace('\r'));

//
// Char.isLower
//

assert (Char.isLower('x'));
assert (not Char.isLower('X'));

//
// Char.isUpper
//

assert (Char.isUpper('X'));
assert (not Char.isUpper('x'));

//
// Char.isAlphabetic
//

assert (Char.isAlphabetic('a'));
assert (Char.isAlphabetic('京'));
assert (not Char.isAlphabetic('㋡'))
