module pnr1_pedagoExample (i0,
    i1,
    i2,
    o0);
 input i0;
 input i1;
 input i2;
 output o0;

 wire _0_;
 wire net1;
 wire net2;
 wire net3;
 wire net4;

 sky130_fd_sc_hd__or2_1 _1_ (.A(net2),
    .B(net1),
    .X(_0_));
 sky130_fd_sc_hd__and2_1 _2_ (.A(net3),
    .B(_0_),
    .X(net4));
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
 sky130_fd_sc_hd__clkbuf_1 input1 (.A(i0),
    .X(net1));
 sky130_fd_sc_hd__clkbuf_1 input2 (.A(i1),
    .X(net2));
 sky130_fd_sc_hd__clkbuf_1 input3 (.A(i2),
    .X(net3));
 sky130_fd_sc_hd__buf_2 output4 (.A(net4),
    .X(o0));
 sky130_ef_sc_hd__decap_12 FILLER_0_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_0_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_0_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_1_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_1_51 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_6 ();
 sky130_fd_sc_hd__decap_8 FILLER_2_18 ();
 sky130_fd_sc_hd__fill_2 FILLER_2_26 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_2_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_2_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_3 ();
 sky130_fd_sc_hd__decap_3 FILLER_3_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_23 ();
 sky130_ef_sc_hd__decap_12 FILLER_3_35 ();
 sky130_fd_sc_hd__decap_6 FILLER_3_47 ();
 sky130_fd_sc_hd__fill_1 FILLER_3_53 ();
 sky130_fd_sc_hd__decap_8 FILLER_4_6 ();
 sky130_fd_sc_hd__decap_3 FILLER_4_14 ();
 sky130_fd_sc_hd__decap_6 FILLER_4_22 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_4_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_4_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_6 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_18 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_30 ();
 sky130_ef_sc_hd__decap_12 FILLER_5_42 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_7 ();
 sky130_fd_sc_hd__decap_8 FILLER_6_19 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_6_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_6_53 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_15 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_7_39 ();
 sky130_fd_sc_hd__decap_3 FILLER_7_51 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_3 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_15 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_27 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_29 ();
 sky130_ef_sc_hd__decap_12 FILLER_8_41 ();
 sky130_fd_sc_hd__fill_1 FILLER_8_53 ();
endmodule
