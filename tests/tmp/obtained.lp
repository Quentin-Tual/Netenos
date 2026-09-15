signal(i0). signal(xor5_w0). signal(i2). signal(xor5_w1). signal(xor5_g3_o0). signal(xor5_w6). signal(i4). signal(xor5_w4). signal(i1). signal(xor5_w2). signal(i3). signal(xor5_w3). signal(xor5_g4_o0). signal(xor5_w5). signal(xor5_g5_o0). signal(xor5_w7). signal(xor5_g6_o0). signal(xor5_w8). signal(xor5_o0).
primary(i0). primary(i2). primary(i4). primary(i1). primary(i3).
edge(r). edge(f).
val(0). val(1).
time(0..766).
% Wire: w0
level0(xor5_w0, 1) :- level0(i0, 1).
level0(xor5_w0, 0) :- level0(i0, 0).
event(xor5_w0, r, T) :- event(i0, r, T-32), time(T).
event(xor5_w0, f, T) :- event(i0, f, T-14), time(T).
% Wire: w1
level0(xor5_w1, 1) :- level0(i2, 1).
level0(xor5_w1, 0) :- level0(i2, 0).
event(xor5_w1, r, T) :- event(i2, r, T-29), time(T).
event(xor5_w1, f, T) :- event(i2, f, T-13), time(T).
% Gate: xor5_g3_o0 = f(xor5_w0, xor5_w1)
level0(xor5_g3_o0, 0) :- level0(xor5_w0, 1), level0(xor5_w1, 1).
level0(xor5_g3_o0, 1) :- level0(xor5_w0, 1), level0(xor5_w1, 0).
level0(xor5_g3_o0, 1) :- level0(xor5_w0, 0), level0(xor5_w1, 1).
level0(xor5_g3_o0, 0) :- level0(xor5_w0, 0), level0(xor5_w1, 0).
event(xor5_g3_o0, f, T) :- event(xor5_w1, r, T-170), steady(xor5_w0, s1, T-170), time(T).
event(xor5_g3_o0, f, T) :- event(xor5_w0, f, T-170), steady(xor5_w1, s0, T-170), time(T).
event(xor5_g3_o0, f, T) :- event(xor5_w0, r, T-170), steady(xor5_w1, s1, T-170), time(T).
event(xor5_g3_o0, f, T) :- event(xor5_w1, f, T-170), steady(xor5_w0, s0, T-170), time(T).
event(xor5_g3_o0, r, T) :- event(xor5_w1, f, T-168), steady(xor5_w0, s1, T-168), time(T).
event(xor5_g3_o0, r, T) :- event(xor5_w0, f, T-168), steady(xor5_w1, s1, T-168), time(T).
event(xor5_g3_o0, r, T) :- event(xor5_w0, r, T-168), steady(xor5_w1, s0, T-168), time(T).
event(xor5_g3_o0, r, T) :- event(xor5_w1, r, T-168), steady(xor5_w0, s0, T-168), time(T).
% Wire: w6
level0(xor5_w6, 1) :- level0(xor5_g3_o0, 1).
level0(xor5_w6, 0) :- level0(xor5_g3_o0, 0).
event(xor5_w6, r, T) :- event(xor5_g3_o0, r, T-0), time(T).
event(xor5_w6, f, T) :- event(xor5_g3_o0, f, T-0), time(T).
% Wire: w4
level0(xor5_w4, 1) :- level0(i4, 1).
level0(xor5_w4, 0) :- level0(i4, 0).
event(xor5_w4, r, T) :- event(i4, r, T-31), time(T).
event(xor5_w4, f, T) :- event(i4, f, T-13), time(T).
% Wire: w2
level0(xor5_w2, 1) :- level0(i1, 1).
level0(xor5_w2, 0) :- level0(i1, 0).
event(xor5_w2, r, T) :- event(i1, r, T-32), time(T).
event(xor5_w2, f, T) :- event(i1, f, T-14), time(T).
% Wire: w3
level0(xor5_w3, 1) :- level0(i3, 1).
level0(xor5_w3, 0) :- level0(i3, 0).
event(xor5_w3, r, T) :- event(i3, r, T-29), time(T).
event(xor5_w3, f, T) :- event(i3, f, T-13), time(T).
% Gate: xor5_g4_o0 = f(xor5_w2, xor5_w3)
level0(xor5_g4_o0, 0) :- level0(xor5_w2, 1), level0(xor5_w3, 1).
level0(xor5_g4_o0, 1) :- level0(xor5_w2, 1), level0(xor5_w3, 0).
level0(xor5_g4_o0, 1) :- level0(xor5_w2, 0), level0(xor5_w3, 1).
level0(xor5_g4_o0, 0) :- level0(xor5_w2, 0), level0(xor5_w3, 0).
event(xor5_g4_o0, f, T) :- event(xor5_w3, r, T-170), steady(xor5_w2, s1, T-170), time(T).
event(xor5_g4_o0, f, T) :- event(xor5_w2, f, T-170), steady(xor5_w3, s0, T-170), time(T).
event(xor5_g4_o0, f, T) :- event(xor5_w2, r, T-170), steady(xor5_w3, s1, T-170), time(T).
event(xor5_g4_o0, f, T) :- event(xor5_w3, f, T-170), steady(xor5_w2, s0, T-170), time(T).
event(xor5_g4_o0, r, T) :- event(xor5_w3, f, T-163), steady(xor5_w2, s1, T-163), time(T).
event(xor5_g4_o0, r, T) :- event(xor5_w2, f, T-163), steady(xor5_w3, s1, T-163), time(T).
event(xor5_g4_o0, r, T) :- event(xor5_w2, r, T-163), steady(xor5_w3, s0, T-163), time(T).
event(xor5_g4_o0, r, T) :- event(xor5_w3, r, T-163), steady(xor5_w2, s0, T-163), time(T).
% Wire: w5
level0(xor5_w5, 1) :- level0(xor5_g4_o0, 1).
level0(xor5_w5, 0) :- level0(xor5_g4_o0, 0).
event(xor5_w5, r, T) :- event(xor5_g4_o0, r, T-0), time(T).
event(xor5_w5, f, T) :- event(xor5_g4_o0, f, T-0), time(T).
% Gate: xor5_g5_o0 = f(xor5_w4, xor5_w5)
level0(xor5_g5_o0, 1) :- level0(xor5_w4, 1), level0(xor5_w5, 1).
level0(xor5_g5_o0, 0) :- level0(xor5_w4, 1), level0(xor5_w5, 0).
level0(xor5_g5_o0, 0) :- level0(xor5_w4, 0), level0(xor5_w5, 1).
level0(xor5_g5_o0, 1) :- level0(xor5_w4, 0), level0(xor5_w5, 0).
event(xor5_g5_o0, f, T) :- event(xor5_w5, f, T-90), steady(xor5_w4, s1, T-90), time(T).
event(xor5_g5_o0, f, T) :- event(xor5_w4, f, T-90), steady(xor5_w5, s1, T-90), time(T).
event(xor5_g5_o0, f, T) :- event(xor5_w4, r, T-90), steady(xor5_w5, s0, T-90), time(T).
event(xor5_g5_o0, f, T) :- event(xor5_w5, r, T-90), steady(xor5_w4, s0, T-90), time(T).
event(xor5_g5_o0, r, T) :- event(xor5_w5, r, T-172), steady(xor5_w4, s1, T-172), time(T).
event(xor5_g5_o0, r, T) :- event(xor5_w4, f, T-172), steady(xor5_w5, s0, T-172), time(T).
event(xor5_g5_o0, r, T) :- event(xor5_w4, r, T-172), steady(xor5_w5, s1, T-172), time(T).
event(xor5_g5_o0, r, T) :- event(xor5_w5, f, T-172), steady(xor5_w4, s0, T-172), time(T).
% Wire: w7
level0(xor5_w7, 1) :- level0(xor5_g5_o0, 1).
level0(xor5_w7, 0) :- level0(xor5_g5_o0, 0).
event(xor5_w7, r, T) :- event(xor5_g5_o0, r, T-0), time(T).
event(xor5_w7, f, T) :- event(xor5_g5_o0, f, T-0), time(T).
% Gate: xor5_g6_o0 = f(xor5_w6, xor5_w7)
level0(xor5_g6_o0, 1) :- level0(xor5_w6, 1), level0(xor5_w7, 1).
level0(xor5_g6_o0, 0) :- level0(xor5_w6, 1), level0(xor5_w7, 0).
level0(xor5_g6_o0, 0) :- level0(xor5_w6, 0), level0(xor5_w7, 1).
level0(xor5_g6_o0, 1) :- level0(xor5_w6, 0), level0(xor5_w7, 0).
event(xor5_g6_o0, f, T) :- event(xor5_w7, f, T-184), steady(xor5_w6, s1, T-184), time(T).
event(xor5_g6_o0, f, T) :- event(xor5_w6, f, T-184), steady(xor5_w7, s1, T-184), time(T).
event(xor5_g6_o0, f, T) :- event(xor5_w6, r, T-184), steady(xor5_w7, s0, T-184), time(T).
event(xor5_g6_o0, f, T) :- event(xor5_w7, r, T-184), steady(xor5_w6, s0, T-184), time(T).
event(xor5_g6_o0, r, T) :- event(xor5_w7, r, T-392), steady(xor5_w6, s1, T-392), time(T).
event(xor5_g6_o0, r, T) :- event(xor5_w6, f, T-392), steady(xor5_w7, s0, T-392), time(T).
event(xor5_g6_o0, r, T) :- event(xor5_w6, r, T-392), steady(xor5_w7, s1, T-392), time(T).
event(xor5_g6_o0, r, T) :- event(xor5_w7, f, T-392), steady(xor5_w6, s0, T-392), time(T).
% Wire: w8
level0(xor5_w8, 1) :- level0(xor5_g6_o0, 1).
level0(xor5_w8, 0) :- level0(xor5_g6_o0, 0).
event(xor5_w8, r, T) :- event(xor5_g6_o0, r, T-0), time(T).
event(xor5_w8, f, T) :- event(xor5_g6_o0, f, T-0), time(T).
% Primary output : xor5_o0
level0(xor5_o0, 1) :- level0(xor5_w8, 1).
level0(xor5_o0, 0) :- level0(xor5_w8, 0).
event(xor5_o0, r, T) :- event(xor5_w8, r, T), time(T).
event(xor5_o0, f, T) :- event(xor5_w8, f, T), time(T).
