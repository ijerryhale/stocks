import Cocoa
import XCPlayground
/*:
## Calculate Pivot Points
This playground will compute Pivot Points for a given prior day OHLC prices
*/

/**
# Pivot Points
Computes standard pivot points
*/

/* VALE 5/18/18 */
let open = 14.73
let high = 14.85
let low = 14.30
let close = 14.57

/* PP = (H + L + C) / 3 */
let pivot = (high + low + close) / 3.00

/* R1 = 2×PP - L */
var r1 = (2 * pivot) - low

/* R2 = PP + H - L) */
var r2 = pivot + (high - low)

/* R3 = H + 2 * (PP - L) */
var r3 = high + 2 * (pivot - low)


/* S1 = 2×PP− - H */
var s1 = (2 * pivot) - high

/* S2 = PP - H - L */
var s2 = pivot - (r1 - s1)

/* S3 = L - 2 * (H - PP) */
var s3 = low - 2 * (high - pivot)


print("Pivot Points")

print("R3:    ", r3)
print("R2:    ", r2)
print("R1:    ", r1)

print("Pivot: ", pivot)

print("S1:    ", s1)
print("S2:    ", s2)
print("S3:    ", s3)
print("\n")

/* Fibonacci */
print("Fibonacci Pivot Points")

let t = high - low

r3 = pivot + (t * 1.000)
r2 = pivot + (t * 0.618)
r1 = pivot + (t * 0.382)

s1 = pivot - (t * 0.382)
s2 = pivot - (t * 0.618)
s3 = pivot - (t * 1.000)

print("Fib R3: ", r3)
print("Fib R2: ", r2)
print("Fib R1: ", r1)

print("Pivot:  ", pivot)

print("Fib S1: ", s1)
print("Fib S2: ", s2)
print("Fib S3: ", s3)
print("\n")

/* Camarilla */
print("Camarilla Pivot Points")

let r4 = close + t * 1.1 / 2
r3 = close + t * 1.1 / 4
r2 = close + t * 1.1 / 6
r1 = close + t * 1.1 / 12

s1 = close - t * 1.1 / 12
s2 = close - t * 1.1 / 6
s3 = close - t * 1.1 / 4
let s4 = close - t * 1.1 / 2

print("Break Out Long:  ", r4)
print("Short:           ", r3)
print("HL2:             ", r2)
print("HL1:             ", r1)

print("Pivot:           ", pivot)

print("LL1:             ", s1)
print("LL2:             ", s2)
print("Long:            ", s3)
print("Break Out Short: ", s4)
