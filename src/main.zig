const std = @import("std");

pub fn Booleanomial(n: u16) type {
    const Int = std.meta.Int(.unsigned, n);
    const N = 1 << n;
    return struct {
        const Self = @This();

        coeffs: [N]i32,

        pub fn init_false() Self {
            return Self{
                .coeffs = [_]i32{0} ** N,
            };
        }

        pub fn init_true() Self {
            var ret = init_false();
            ret.coeffs[0] = 1;
            return ret;
        }

        pub fn init(comptime z: u16) Self {
            comptime std.debug.assert(z < n);
            var ret = init_false();
            ret.coeffs[1 << z] = 1;
            return ret;
        }

        fn mul(self: Self, other: Self) Self {
            var ret = init_false();
            var x: Int = 0;
            while (true) : (x += 1) {
                var y: Int = 0;
                while (true) : (y += 1) {
                    ret.coeffs[x | y] += self.coeffs[x] * other.coeffs[y];
                    if (y == N - 1) {
                        break;
                    }
                }
                if (x == N - 1) {
                    break;
                }
            }
            return ret;
        }

        pub fn @"not"(self: Self) Self {
            var ret = init_false();
            ret.coeffs[0] = 1 - self.coeffs[0];
            var x: Int = 1;
            while (true) : (x += 1) {
                ret.coeffs[x] = -self.coeffs[x];
                if (x == N - 1) {
                    break;
                }
            }
            return ret;
        }

        pub fn @"and"(self: Self, other: Self) Self {
            return self.mul(other);
        }

        pub fn @"or"(self: Self, other: Self) Self {
            var ret = self.mul(other);
            var x: Int = 0;
            while (true) : (x += 1) {
                ret.coeffs[x] = -ret.coeffs[x] + self.coeffs[x] + other.coeffs[x];
                if (x == N - 1) {
                    break;
                }
            }
            return ret;
        }

        pub fn @"xor"(self: Self, other: Self) Self {
            var ret = self.mul(other);
            var x: Int = 0;
            while (true) : (x += 1) {
                ret.coeffs[x] = -2 * ret.coeffs[x] + self.coeffs[x] + other.coeffs[x];
                if (x == N - 1) {
                    break;
                }
            }
            return ret;
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = options;
            comptime std.debug.assert(fmt.len == n);
            var iter = BitCombinationIterator(n){};
            var leading = true;

            while (iter.next()) |bitset| {
                var c = self.coeffs[bitset.mask];

                if (c == 0) {
                    continue;
                }

                if (leading) {
                    var mag = std.math.absInt(c) catch unreachable;
                    if (c < 0) {
                        try writer.print("-", .{});
                    }
                    if (mag != 1) {
                        try writer.print("{}", .{mag});
                    }
                    leading = false;
                } else {
                    var mag = std.math.absInt(c) catch unreachable;
                    if (c < 0) {
                        try writer.print(" - ", .{});
                    } else {
                        try writer.print(" + ", .{});
                    }
                    if (mag != 1 or bitset.mask == 0) {
                        try writer.print("{}", .{mag});
                    }
                }

                var x: usize = 0;
                while (x < n) : (x += 1) {
                    if (bitset.isSet(x)) {
                        try writer.print("{c}", .{fmt[x]});
                    }
                }
            }
        }
    };
}

pub fn BitCombinationIterator(n: u16) type {
    const BitSet = std.bit_set.IntegerBitSet(n);

    return struct {
        const Self = @This();

        bitset: ?BitSet = BitSet.initFull(),

        pub fn next(self: *Self) ?BitSet {
            var ret = self.bitset;
            if (self.bitset) |bitset| {
                var i: usize = 1;
                var b: usize = 0;
                while (i < n) : (i += 1) {
                    var last = bitset.isSet(i - 1);
                    var curr = bitset.isSet(i);

                    if (last and !curr) {
                        self.bitset.?.set(i);
                        self.bitset.?.setRangeValue(.{ .start = 0, .end = b }, true);
                        self.bitset.?.setRangeValue(.{ .start = b, .end = i }, false);
                        return ret;
                    } else if (last) {
                        b += 1;
                    }
                }

                var c = bitset.count();

                if (c == 0) {
                    self.bitset = null;
                } else {
                    self.bitset.?.setRangeValue(.{ .start = 0, .end = c - 1 }, true);
                    self.bitset.?.setRangeValue(.{ .start = c - 1, .end = n }, false);
                }
            }
            return ret;
        }
    };
}

pub fn main() void {
    var a = Booleanomial(4).init(0);
    var b = Booleanomial(4).init(1);
    var c = Booleanomial(4).init(2);
    var d = Booleanomial(4).init(3);

    // basic
    var @"not a" = a.@"not"();
    std.debug.print("not a   = {abcd}\n", .{@"not a"});

    var @"a and b" = a.@"and"(b);
    std.debug.print("a and b = {abcd}\n", .{@"a and b"});

    var @"a or b" = a.@"or"(b);
    std.debug.print("a or b  = {abcd}\n", .{@"a or b"});

    var @"a xor b" = a.@"xor"(b);
    std.debug.print("a xor b = {abcd}\n", .{@"a xor b"});

    std.debug.print("\n", .{});

    // advanced
    var @"c and (a or b)" = c.@"and"(@"a or b");
    std.debug.print("c and (a or b)      = {abcd}\n", .{@"c and (a or b)"});

    var @"a and b and c and d" = @"a and b".@"and"(c).@"and"(d);
    std.debug.print("a and b and c and d = {abcd}\n", .{@"a and b and c and d"});

    var @"a or b or c or d" = @"a or b".@"or"(c).@"or"(d);
    std.debug.print("a or b or c or d    = {abcd}\n", .{@"a or b or c or d"});

    var @"a xor b xor c xor d" = @"a xor b".@"xor"(c).@"xor"(d);
    std.debug.print("a xor b xor c xor d = {abcd}\n", .{@"a xor b xor c xor d"});

    var @"(a and b) or (c and (a xor b))" = @"a and b".@"or"(c.@"and"(@"a xor b"));
    std.debug.print("(a and b) or (c and (a xor b)) = {abcd}\n", .{@"(a and b) or (c and (a xor b))"});
}
