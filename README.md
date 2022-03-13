# Booleanomial v2 Electric Boogaloo

100x more cursed + Zig

do not read the source code

* [v1](https://github.com/SnootierMoon/Booleanomial)
* [Zig Helper](https://gist.github.com/SnootierMoon/953a2a92e1ea662be3c49c4737b8bc45)

Features:

- supports logical not, and, or, xor
- (new in v2) proper polynomial ordering (greatest degree first + lexicographic
  but i'm not really sure if i know what that word means)

## Waht are booleanomaisld

Truth tables for the utterly deranged

Polynomial form, and everything must evaluate to 0 or 1.
0=false, 1=true. 
A valid booleanomial evaluates to 0 or 1 for all inputs that are 0 or 1.

## RUN.

`zig build run`

requires Zig v0.10 probably (for `std.bit_set.IntegerBitSet.setRangeValue`)

## Who?

asked

## Output

```
not a   = -a + 1
a and b = ab
a or b  = -ab + a + b
a xor b = -2ab + a + b

c and (a or b)      = -abc + ac + bc
a and b and c and d = abcd
a or b or c or d    = -abcd + abc + abd + acd + bcd - ab - ac - bc - ad - bd - cd + a + b + c + d
a xor b xor c xor d = -8abcd + 4abc + 4abd + 4acd + 4bcd - 2ab - 2ac - 2bc - 2ad - 2bd - 2cd + a + b + c + d
(a and b) or (c and (a xor b)) = -2abc + ab + ac + bc
```
