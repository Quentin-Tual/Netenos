module xor5 (i0,
    i1,
    i2,
    i3,
    i4,
    o0);
 input i0;
 input i1;
 input i2;
 input i3;
 input i4;
 output o0;

 wire _0_;
 wire _1_;
 wire _2_;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;

 sky130_fd_sc_hd__xor2_1 _3_ (.A(net1),
    .B(net3),
    .X(_0_));
 sky130_fd_sc_hd__xor2_1 _4_ (.A(net2),
    .B(net4),
    .X(_1_));
 sky130_fd_sc_hd__xnor2_1 _5_ (.A(net5),
    .B(_1_),
    .Y(_2_));
 sky130_fd_sc_hd__xnor2_1 _6_ (.A(_0_),
    .B(_2_),
    .Y(net6));
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Right_0 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Right_1 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Right_2 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Right_3 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Right_4 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Right_5 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Right_6 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Right_7 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Right_8 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Right_9 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Right_10 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Right_11 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Right_12 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_0_Left_13 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_1_Left_14 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_2_Left_15 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_3_Left_16 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_4_Left_17 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_5_Left_18 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_6_Left_19 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_7_Left_20 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_8_Left_21 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_9_Left_22 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_10_Left_23 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_11_Left_24 ();
 sky130_fd_sc_hd__decap_3 PHY_EDGE_ROW_12_Left_25 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_26 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_0_27 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_1_28 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_2_29 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_3_30 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_4_31 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_5_32 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_6_33 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_7_34 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_8_35 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_9_36 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_10_37 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_11_38 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_39 ();
 sky130_fd_sc_hd__tapvpwrvgnd_1 TAP_TAPCELL_ROW_12_40 ();
 sky130_fd_sc_hd__clkbuf_1 input1 (.A(i0),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_1 input2 (.A(i1),
    .X(net2));
 sky130_fd_sc_hd__clkbuf_1 input3 (.A(i2),
    .X(net3));
 sky130_fd_sc_hd__clkbuf_1 input4 (.A(i3),
    .X(net4));
 sky130_fd_sc_hd__clkbuf_1 input5 (.A(i4),
    .X(net5));
 sky130_fd_sc_hd__buf_2 output6 (.A(net6),
    .X(o0));
 sky130_ef_sc_hd__decap_12 FILLER_0_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_0_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_0_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_39 ();
 sky130_fd_sc_hd__decap_4 FILLER_1_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_1_55 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_1_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_53 ();
 sky130_fd_sc_hd__decap_8 FILLER_2_65 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_73 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_39 ();
 sky130_fd_sc_hd__decap_4 FILLER_3_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_55 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_3_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_18 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_53 ();
 sky130_fd_sc_hd__decap_8 FILLER_4_65 ();
 sky130_fd_sc_hd__fill_2 FILLER_4_73 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_6 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_18 ();
 sky130_fd_sc_hd__decap_4 FILLER_5_30 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_5_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_5_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_6_18 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_53 ();
 sky130_fd_sc_hd__decap_6 FILLER_6_65 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_18 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_28 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_40 ();
 sky130_fd_sc_hd__decap_4 FILLER_7_52 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_7_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_53 ();
 sky130_fd_sc_hd__decap_8 FILLER_8_65 ();
 sky130_fd_sc_hd__fill_2 FILLER_8_73 ();
 sky130_ef_sc_hd__decap_12 FILLER_9_6 ();
 sky130_ef_sc_hd__decap_12 FILLER_9_18 ();
 sky130_ef_sc_hd__decap_12 FILLER_9_30 ();
 sky130_ef_sc_hd__decap_12 FILLER_9_42 ();
 sky130_fd_sc_hd__fill_2 FILLER_9_54 ();
 sky130_ef_sc_hd__decap_12 FILLER_9_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_9_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_10_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_10_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_10_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_10_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_10_41 ();
 sky130_ef_sc_hd__decap_12 FILLER_10_53 ();
 sky130_fd_sc_hd__decap_8 FILLER_10_65 ();
 sky130_fd_sc_hd__fill_2 FILLER_10_73 ();
 sky130_ef_sc_hd__decap_12 FILLER_11_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_11_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_11_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_11_39 ();
 sky130_fd_sc_hd__decap_4 FILLER_11_51 ();
 sky130_fd_sc_hd__fill_1 FILLER_11_55 ();
 sky130_ef_sc_hd__decap_12 FILLER_11_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_11_69 ();
 sky130_ef_sc_hd__decap_12 FILLER_12_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_12_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_12_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_12_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_12_41 ();
 sky130_fd_sc_hd__decap_3 FILLER_12_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_12_57 ();
 sky130_fd_sc_hd__decap_6 FILLER_12_69 ();
endmodule
