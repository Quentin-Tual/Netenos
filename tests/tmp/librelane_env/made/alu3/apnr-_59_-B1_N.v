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
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire eco_buffer_0_net;

 sky130_fd_sc_hd__inv_2 _28_ (.A(net5),
    .Y(_00_));
 sky130_fd_sc_hd__and2b_1 _29_ (.A_N(net7),
    .B(net3),
    .X(_01_));
 sky130_fd_sc_hd__and2b_1 _30_ (.A_N(net2),
    .B(net1),
    .X(_02_));
 sky130_fd_sc_hd__xnor2_1 _31_ (.A(_01_),
    .B(_02_),
    .Y(net11));
 sky130_fd_sc_hd__nand2_1 _32_ (.A(net3),
    .B(net1),
    .Y(_03_));
 sky130_fd_sc_hd__o21ai_1 _33_ (.A1(net7),
    .A2(net1),
    .B1(net3),
    .Y(_04_));
 sky130_fd_sc_hd__and2b_1 _34_ (.A_N(net8),
    .B(net4),
    .X(_05_));
 sky130_fd_sc_hd__a21oi_1 _35_ (.A1(net3),
    .A2(net1),
    .B1(net7),
    .Y(_06_));
 sky130_fd_sc_hd__o21ai_1 _36_ (.A1(net2),
    .A2(_06_),
    .B1(_05_),
    .Y(_07_));
 sky130_fd_sc_hd__o31a_1 _37_ (.A1(net2),
    .A2(_04_),
    .A3(_05_),
    .B1(_07_),
    .X(net12));
 sky130_fd_sc_hd__nand2b_1 _38_ (.A_N(net9),
    .B(net5),
    .Y(_08_));
 sky130_fd_sc_hd__nor2_1 _39_ (.A(net8),
    .B(net9),
    .Y(_09_));
 sky130_fd_sc_hd__or2_1 _40_ (.A(net8),
    .B(net9),
    .X(_10_));
 sky130_fd_sc_hd__a21o_1 _41_ (.A1(net7),
    .A2(net4),
    .B1(net8),
    .X(_11_));
 sky130_fd_sc_hd__and3_1 _42_ (.A(net3),
    .B(net1),
    .C(net4),
    .X(_12_));
 sky130_fd_sc_hd__nor2_1 _43_ (.A(_11_),
    .B(_12_),
    .Y(_13_));
 sky130_fd_sc_hd__o21ai_1 _44_ (.A1(net2),
    .A2(_13_),
    .B1(_08_),
    .Y(_14_));
 sky130_fd_sc_hd__a2bb2o_1 _45_ (.A1_N(net4),
    .A2_N(net9),
    .B1(_04_),
    .B2(_09_),
    .X(_15_));
 sky130_fd_sc_hd__o31a_1 _46_ (.A1(net2),
    .A2(_08_),
    .A3(_15_),
    .B1(_14_),
    .X(net13));
 sky130_fd_sc_hd__and2b_1 _47_ (.A_N(net10),
    .B(net6),
    .X(_16_));
 sky130_fd_sc_hd__or4bb_1 _48_ (.A(_01_),
    .B(_05_),
    .C_N(_08_),
    .D_N(net2),
    .X(_17_));
 sky130_fd_sc_hd__o41a_1 _49_ (.A1(net3),
    .A2(net1),
    .A3(net4),
    .A4(net5),
    .B1(_17_),
    .X(_18_));
 sky130_fd_sc_hd__or3b_1 _50_ (.A(net2),
    .B(net10),
    .C_N(net6),
    .X(_19_));
 sky130_fd_sc_hd__a21oi_1 _51_ (.A1(net5),
    .A2(_11_),
    .B1(net9),
    .Y(_20_));
 sky130_fd_sc_hd__a221o_1 _52_ (.A1(net4),
    .A2(net9),
    .B1(_10_),
    .B2(net3),
    .C1(net1),
    .X(_21_));
 sky130_fd_sc_hd__or4b_1 _53_ (.A(net8),
    .B(_03_),
    .C(_08_),
    .D_N(net4),
    .X(_22_));
 sky130_fd_sc_hd__o22a_1 _54_ (.A1(_20_),
    .A2(_21_),
    .B1(_22_),
    .B2(net7),
    .X(_23_));
 sky130_fd_sc_hd__o22ai_1 _55_ (.A1(_16_),
    .A2(_18_),
    .B1(_19_),
    .B2(_23_),
    .Y(net14));
 sky130_fd_sc_hd__o21a_1 _56_ (.A1(_11_),
    .A2(_12_),
    .B1(net5),
    .X(_24_));
 sky130_fd_sc_hd__o21a_1 _57_ (.A1(net9),
    .A2(_24_),
    .B1(net6),
    .X(_25_));
 sky130_fd_sc_hd__or2_1 _58_ (.A(net10),
    .B(_25_),
    .X(net15));
 sky130_fd_sc_hd__o21ba_1 _59_ (.A1(net9),
    .A2(_24_),
    .B1_N(eco_buffer_0_net),
    .X(_26_));
 sky130_fd_sc_hd__o32a_1 _60_ (.A1(_00_),
    .A2(_15_),
    .A3(_19_),
    .B1(_26_),
    .B2(_16_),
    .X(net16));
 sky130_fd_sc_hd__o221a_1 _61_ (.A1(net4),
    .A2(net9),
    .B1(_10_),
    .B2(net7),
    .C1(net5),
    .X(_27_));
 sky130_fd_sc_hd__o21ai_1 _62_ (.A1(net10),
    .A2(_27_),
    .B1(net6),
    .Y(net17));
 sky130_fd_sc_hd__and4_1 _63_ (.A(net3),
    .B(net4),
    .C(net5),
    .D(net6),
    .X(net18));
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_9 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_17 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_18 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_19 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_20 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_21 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_22 ();
 sky130_fd_sc_hd__clkbuf_2 input1 (.A(i0),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_2 input2 (.A(i1),
    .X(net2));
 sky130_fd_sc_hd__clkbuf_2 input3 (.A(i2),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_2 input4 (.A(i3),
    .X(net4));
 sky130_fd_sc_hd__clkbuf_2 input5 (.A(i4),
    .X(net5));
 sky130_fd_sc_hd__buf_1 input6 (.A(i5),
    .X(net6));
 sky130_fd_sc_hd__dlymetal6s2s_1 input7 (.A(i6),
    .X(net7));
 sky130_fd_sc_hd__buf_1 input8 (.A(i7),
    .X(net8));
 sky130_fd_sc_hd__clkbuf_2 input9 (.A(i8),
    .X(net9));
 sky130_fd_sc_hd__buf_1 input10 (.A(i9),
    .X(net10));
 sky130_fd_sc_hd__buf_2 output11 (.A(net11),
    .X(o0));
 sky130_fd_sc_hd__buf_2 output12 (.A(net12),
    .X(o1));
 sky130_fd_sc_hd__buf_2 output13 (.A(net13),
    .X(o2));
 sky130_fd_sc_hd__buf_2 output14 (.A(net14),
    .X(o3));
 sky130_fd_sc_hd__buf_2 output15 (.A(net15),
    .X(o4));
 sky130_fd_sc_hd__buf_2 output16 (.A(net16),
    .X(o5));
 sky130_fd_sc_hd__buf_2 output17 (.A(net17),
    .X(o6));
 sky130_fd_sc_hd__buf_2 output18 (.A(net18),
    .X(o7));
 sky130_fd_sc_hd__buf_8 eco_buffer_0 (.A(net2),
    .X(eco_buffer_0_net));
 sky130_ef_sc_hd__decap_12 FILLER_0_3 ();
 sky130_fd_sc_hd__fill_2 FILLER_0_15 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_21 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_29 ();
 sky130_fd_sc_hd__decap_6 FILLER_1_7 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_13 ();
 sky130_fd_sc_hd__decap_4 FILLER_1_29 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_39 ();
 sky130_fd_sc_hd__decap_6 FILLER_2_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_2_25 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_47 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_3 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_10 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_14 ();
 sky130_fd_sc_hd__decap_8 FILLER_3_40 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_48 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_19 ();
 sky130_fd_sc_hd__decap_4 FILLER_4_38 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_33 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_41 ();
 sky130_fd_sc_hd__fill_2 FILLER_5_47 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_11 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_17 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_25 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_29 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_35 ();
 sky130_fd_sc_hd__fill_2 FILLER_6_51 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_22 ();
 sky130_fd_sc_hd__fill_1 FILLER_7_52 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_27 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_29 ();
 sky130_fd_sc_hd__decap_8 FILLER_8_35 ();
endmodule
