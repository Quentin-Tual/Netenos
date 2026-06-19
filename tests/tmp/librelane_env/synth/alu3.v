// Benchmark "alu3" written by ABC on Fri Jun 19 12:58:24 2026

module alu3 ( 
    i0, i1, i2, i3, i4, i5, i6, i7, i8, i9,
    o0, o1, o2, o3, o4, o5, o6, o7  );
  input  i0, i1, i2, i3, i4, i5, i6, i7, i8, i9;
  output o0, o1, o2, o3, o4, o5, o6, o7;
  assign o0 = (i2 & ~i6) ^ (~i0 | i1);
  assign o1 = ((~i3 | i7) & (i1 | ~i2 | (~i0 & ~i6))) | (~i1 & i3 & ~i7 & (i6 | (i0 & i2)));
  assign o2 = (~i1 & (~i4 | i8) & (i7 | (i3 & (i6 | (i0 & i2))))) | (i4 & ~i8 & ((~i7 & (~i2 | (~i0 & ~i6))) | i1 | ~i3));
  assign o3 = (~i1 & i5 & ~i9 & ((~i0 & ((~i2 & ((~i3 & i8) | (i4 & i7 & ~i8))) | (i3 & i4 & i6 & ~i7 & ~i8))) | (i0 & i2 & i3 & ~i7 & ~i8 & i4 & ~i6))) | ((~i5 | i9) & ((i1 & (~i4 | i8) & (~i3 | i7) & (~i2 | i6)) | (~i0 & ~i2 & ~i3 & ~i4)));
  assign o4 = i9 | (i5 & (i8 | (i4 & (i7 | (i3 & (i6 | (i0 & i2)))))));
  assign o5 = (~i1 & (~i5 | i9) & (i8 | (i4 & (i7 | (i3 & (i6 | (i0 & i2))))))) | (i5 & ~i9 & ((~i8 & (~i3 | (~i7 & (~i2 | (~i0 & ~i6))))) | i1 | ~i4));
  assign o6 = ~i5 | (~i9 & (~i4 | (~i8 & (~i3 | (~i6 & ~i7)))));
  assign o7 = i5 & i4 & i2 & i3;
endmodule


