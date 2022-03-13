const std = @import("std");

pub fn Booleanomial(n: u16) type {
    const Int = std.meta.Int(.unsigned, n);
    const N = 1 << n;
    return struct {
        const Self = @This();

        coeffs: [N]i32,

        pub fn init_false() Self {
            return Self{
                .coeffs = [1]i32{0} ** N,
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

        pub fn lnot(self: Self) Self {
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

        pub fn land(self: Self, other: Self) Self {
            return self.mul(other);
        }

        pub fn lor(self: Self, other: Self) Self {
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

        pub fn lxor(self: Self, other: Self) Self {
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

                var mag = std.math.absInt(c) catch unreachable;
                if (c < 0) {
                    if (leading) {
                        try writer.print("-", .{});
                    } else {
                        try writer.print(" - ", .{});
                    }
                } else if (!leading) {
                    try writer.print(" + ", .{});
                }
                if (mag != 1 or bitset.mask == 0) {
                    try writer.print("{}", .{mag});
                }
                leading = false;

                var x: usize = 0;
                while (x < n) : (x += 1) {
                    if (bitset.isSet(x)) {
                        try writer.print("{c}", .{fmt[x]});
                    }
                }
            }

            if (leading) {
                try writer.print("0", .{});
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
    var t = Booleanomial(4).init_true();
    var f = Booleanomial(4).init_false();

    var a = Booleanomial(4).init(0);
    var b = Booleanomial(4).init(1);
    var c = Booleanomial(4).init(2);
    var d = Booleanomial(4).init(3);

    // basic
    std.debug.print("a       = {abcd}\n", .{a});
    std.debug.print("b       = {abcd}\n", .{b});
    std.debug.print("c       = {abcd}\n", .{c});

    var @"not a" = a.lnot();
    std.debug.print("not a   = {abcd}\n", .{@"not a"});

    var @"a and b" = a.land(b);
    std.debug.print("a and b = {abcd}\n", .{@"a and b"});

    var @"a or b" = a.lor(b);
    std.debug.print("a or b  = {abcd}\n", .{@"a or b"});

    var @"a xor b" = a.lxor(b);
    std.debug.print("a xor b = {abcd}\n", .{@"a xor b"});
    std.debug.print("\n", .{});

    // true and false
    std.debug.print("true        = {abcd}\n", .{t});
    std.debug.print("false       = {abcd}\n", .{f});

    var @"not true" = t.lnot();
    std.debug.print("not true    = {abcd}\n", .{@"not true"});
    var @"not false" = f.lnot();
    std.debug.print("not false   = {abcd}\n", .{@"not false"});

    var @"a or true" = a.lor(t);
    std.debug.print("a or true   = {abcd}\n", .{@"a or true"});
    var @"a and true" = a.land(t);
    std.debug.print("a and true  = {abcd}\n", .{@"a and true"});
    var @"a xor true" = a.lxor(t);
    std.debug.print("a xor true  = {abcd}\n", .{@"a xor true"});
    var @"a or false" = a.lor(f);
    std.debug.print("a or false  = {abcd}\n", .{@"a or false"});
    var @"a and false" = a.land(f);
    std.debug.print("a and false = {abcd}\n", .{@"a and false"});
    var @"a xor false" = a.lxor(f);
    std.debug.print("a xor false = {abcd}\n", .{@"a xor false"});

    std.debug.print("\n", .{});

    // advanced
    var @"c and (a or b)" = c.land(@"a or b");
    std.debug.print("c and (a or b)      = {abcd}\n", .{@"c and (a or b)"});

    var @"a and b and c and d" = @"a and b".land(c).land(d);
    std.debug.print("a and b and c and d = {abcd}\n", .{@"a and b and c and d"});

    var @"a or b or c or d" = @"a or b".lor(c).lor(d);
    std.debug.print("a or b or c or d    = {abcd}\n", .{@"a or b or c or d"});

    var @"a xor b xor c xor d" = @"a xor b".lxor(c).lxor(d);
    std.debug.print("a xor b xor c xor d = {abcd}\n", .{@"a xor b xor c xor d"});

    var @"(a and b) or (c and (a xor b))" = @"a and b".lor(c.land(@"a xor b"));
    std.debug.print("(a and b) or (c and (a xor b)) = {abcd}\n", .{@"(a and b) or (c and (a xor b))"});
}
