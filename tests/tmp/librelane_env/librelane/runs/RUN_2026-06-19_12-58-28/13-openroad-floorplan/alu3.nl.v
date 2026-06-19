module alu3 (i0,
    i1,
    i2,
    i3,
    i4,
    i5,
    i6,
    i7,
    i8,
    i9,
    o0,
    o1,
    o2,
    o3,
    o4,
    o5,
    o6,
    o7);
 input i0;
 input i1;
 input i2;
 input i3;
 input i4;
 input i5;
 input i6;
 input i7;
 input i8;
 input i9;
 output o0;
 output o1;
 output o2;
 output o3;
 output o4;
 output o5;
 output o6;
 output o7;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire _11_;
 wire _12_;
 wire _13_;
 wire _14_;
 wire _15_;
 wire _16_;
 wire _17_;
 wire _18_;
 wire _19_;
 wire _20_;
 wire _21_;
 wire _22_;
 wire _23_;
 wire _24_;
 wire _25_;
 wire _26_;
 wire _27_;

 sky130_fd_sc_hd__inv_2 _28_ (.A(i4),
    .Y(_00_));
 sky130_fd_sc_hd__and2b_2 _29_ (.A_N(i6),
    .B(i2),
    .X(_01_));
 sky130_fd_sc_hd__and2b_2 _30_ (.A_N(i1),
    .B(i0),
    .X(_02_));
 sky130_fd_sc_hd__xnor2_2 _31_ (.A(_01_),
    .B(_02_),
    .Y(o0));
 sky130_fd_sc_hd__nand2_2 _32_ (.A(i2),
    .B(i0),
    .Y(_03_));
 sky130_fd_sc_hd__o21ai_2 _33_ (.A1(i6),
    .A2(i0),
    .B1(i2),
    .Y(_04_));
 sky130_fd_sc_hd__and2b_2 _34_ (.A_N(i7),
    .B(i3),
    .X(_05_));
 sky130_fd_sc_hd__a21oi_2 _35_ (.A1(i2),
    .A2(i0),
    .B1(i6),
    .Y(_06_));
 sky130_fd_sc_hd__o21ai_2 _36_ (.A1(i1),
    .A2(_06_),
    .B1(_05_),
    .Y(_07_));
 sky130_fd_sc_hd__o31a_2 _37_ (.A1(i1),
    .A2(_04_),
    .A3(_05_),
    .B1(_07_),
    .X(o1));
 sky130_fd_sc_hd__nand2b_2 _38_ (.A_N(i8),
    .B(i4),
    .Y(_08_));
 sky130_fd_sc_hd__nor2_2 _39_ (.A(i7),
    .B(i8),
    .Y(_09_));
 sky130_fd_sc_hd__or2_2 _40_ (.A(i7),
    .B(i8),
    .X(_10_));
 sky130_fd_sc_hd__a21o_2 _41_ (.A1(i6),
    .A2(i3),
    .B1(i7),
    .X(_11_));
 sky130_fd_sc_hd__and3_2 _42_ (.A(i2),
    .B(i0),
    .C(i3),
    .X(_12_));
 sky130_fd_sc_hd__nor2_2 _43_ (.A(_11_),
    .B(_12_),
    .Y(_13_));
 sky130_fd_sc_hd__o21ai_2 _44_ (.A1(i1),
    .A2(_13_),
    .B1(_08_),
    .Y(_14_));
 sky130_fd_sc_hd__a2bb2o_2 _45_ (.A1_N(i3),
    .A2_N(i8),
    .B1(_04_),
    .B2(_09_),
    .X(_15_));
 sky130_fd_sc_hd__o31a_2 _46_ (.A1(i1),
    .A2(_08_),
    .A3(_15_),
    .B1(_14_),
    .X(o2));
 sky130_fd_sc_hd__and2b_2 _47_ (.A_N(i9),
    .B(i5),
    .X(_16_));
 sky130_fd_sc_hd__or4bb_2 _48_ (.A(_01_),
    .B(_05_),
    .C_N(_08_),
    .D_N(i1),
    .X(_17_));
 sky130_fd_sc_hd__o41a_2 _49_ (.A1(i2),
    .A2(i0),
    .A3(i3),
    .A4(i4),
    .B1(_17_),
    .X(_18_));
 sky130_fd_sc_hd__or3b_2 _50_ (.A(i1),
    .B(i9),
    .C_N(i5),
    .X(_19_));
 sky130_fd_sc_hd__a21oi_2 _51_ (.A1(i4),
    .A2(_11_),
    .B1(i8),
    .Y(_20_));
 sky130_fd_sc_hd__a221o_2 _52_ (.A1(i3),
    .A2(i8),
    .B1(_10_),
    .B2(i2),
    .C1(i0),
    .X(_21_));
 sky130_fd_sc_hd__or4b_2 _53_ (.A(i7),
    .B(_03_),
    .C(_08_),
    .D_N(i3),
    .X(_22_));
 sky130_fd_sc_hd__o22a_2 _54_ (.A1(_20_),
    .A2(_21_),
    .B1(_22_),
    .B2(i6),
    .X(_23_));
 sky130_fd_sc_hd__o22ai_2 _55_ (.A1(_16_),
    .A2(_18_),
    .B1(_19_),
    .B2(_23_),
    .Y(o3));
 sky130_fd_sc_hd__o21a_2 _56_ (.A1(_11_),
    .A2(_12_),
    .B1(i4),
    .X(_24_));
 sky130_fd_sc_hd__o21a_2 _57_ (.A1(i8),
    .A2(_24_),
    .B1(i5),
    .X(_25_));
 sky130_fd_sc_hd__or2_2 _58_ (.A(i9),
    .B(_25_),
    .X(o4));
 sky130_fd_sc_hd__o21ba_2 _59_ (.A1(i8),
    .A2(_24_),
    .B1_N(i1),
    .X(_26_));
 sky130_fd_sc_hd__o32a_2 _60_ (.A1(_00_),
    .A2(_15_),
    .A3(_19_),
    .B1(_26_),
    .B2(_16_),
    .X(o5));
 sky130_fd_sc_hd__o221a_2 _61_ (.A1(i3),
    .A2(i8),
    .B1(_10_),
    .B2(i6),
    .C1(i4),
    .X(_27_));
 sky130_fd_sc_hd__o21ai_2 _62_ (.A1(i9),
    .A2(_27_),
    .B1(i5),
    .Y(o6));
 sky130_fd_sc_hd__and4_2 _63_ (.A(i2),
    .B(i3),
    .C(i4),
    .D(i5),
    .X(o7));
endmodule
