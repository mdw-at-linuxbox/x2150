// index by: {t1,t2,r1,r2,r2a,r5}
unsigned char tt_to_uc[64] = {
//  not           F     G                 B     C
   0x5f, 0x00, 0xc6, 0xc7, 0x00, 0x00, 0xc2, 0xc3,	// 0-7
//    I     H     D     E                 +     A
   0xc9, 0xc8, 0xc4, 0xc5, 0x00, 0x00, 0x4e, 0xc1,	// 8-f
//    !           W     X                 S     T
   0x5a, 0x00, 0xe6, 0xe7, 0x00, 0x00, 0xe2, 0xe3,	// 10-17
//    Z     Y     U     V              cent     ?
   0xe9, 0xe8, 0xe4, 0xe5, 0x00, 0x00, 0x4a, 0x6f,	// 18-1f
//    |           O     P                 K     L
   0x4f, 0x00, 0xd6, 0xd7, 0x00, 0x00, 0xd2, 0xd3,	// 20-27
//    R     Q     M     N                 _     J
   0xd9, 0xd8, 0xd4, 0xd5, 0x00, 0x00, 0x6d, 0xd1,	// 28-2f
//    "     )     '     >                 <     ;
   0x7f, 0x5d, 0x7d, 0x6e, 0x00, 0x00, 0x4c, 0x5e,	// 30-37
//    (     *     :     %                       =
   0x4d, 0x5c, 0x7a, 0x6c, 0x00, 0x000, 0x00, 0x7e	// 38-3f
};
unsigned char tt_to_lc[64] = {
//    .           f     g                 b     c
   0x4b, 0x00, 0x86, 0x87, 0x00, 0x00, 0x82, 0x83,	// 0-7
//    i     h     d     e                 &     a
   0x89, 0x88, 0x84, 0x85, 0x00, 0x00, 0x50, 0x81,	// 8-f
//    ,           w     x                 s     t
   0x6b, 0x00, 0xa6, 0xa7, 0x00, 0x00, 0xa2, 0xa3,	// 10-17
//    z     y     u     v                 @     /
   0xa9, 0xa8, 0xa4, 0xa5, 0x00, 0x00, 0x7c, 0x61,	// 18-1f
//    $           o     p                 k     l
   0x5b, 0x00, 0x96, 0x97, 0x00, 0x00, 0x92, 0x93,	// 20-27
//    r     q     m     n                 -     j
   0x99, 0x98, 0x94, 0x95, 0x00, 0x00, 0x60, 0x91,	// 28-2f
//    #     0     6     7                 2     3
   0x7b, 0xf0, 0xf6, 0xf7, 0x00, 0x00, 0xf2, 0xf3,	// 30-37
//    9     8     4     5                       1
   0xf9, 0xf8, 0xf4, 0xf5, 0x00, 0x00, 0x00, 0xf1	// 38-3f
};
unsigned short e_to_tt[256] = {
//                                                        	// 0 - 7
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 8 - f
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 10 - 17
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 18 - 1f
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 20 - 27
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 28 - 2f
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 30 - 37
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 38 - 3f
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// 40 - 47
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                 cent      .      <      (      +      !	// 48 - 4f
     0377,  0377,   036,  0100,   066,   070,   016,   040,
//      &                                                 	// 50 - 57
     0116,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                    |      $      *      )      ;    not	// 58 - 5f
     0377,  0377,   020,  0140,   071,   061,   067,     0,
//      -      /                                          	// 60 - 67
     0156,  0137,  0377,  0377,  0377,  0377,  0377,  0377,
//                           ,      %      _      >      ?	// 68 - 6f
     0377,  0377,  0377,  0120,   073,   056,   063,   037,
//                                                        	// 70 - 77
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                    :      #      @      '      =      "	// 78 - 7f
     0377,  0377,   072,  0160,  0136,   062,   077,   060,
//             a      b      c      d      e      f      g	// 80 - 87
     0377,  0117,  0106,  0107,  0112,  0113,  0102,  0103,
//      h      i                                          	// 88 - 8f
     0111,  0110,  0377,  0377,  0377,  0377,  0377,  0377,
//             j      k      l      m      n      o      p	// 90 - 97
     0377,  0157,  0146,  0147,  0152,  0153,  0142,  0143,
//      q      r                                          	// 98 - 9f
     0151,  0150,  0377,  0377,  0377,  0377,  0377,  0377,
//                    s      t      u      v      w      x	// a0 - a7
     0377,  0377,  0126,  0127,  0132,  0133,  0122,  0123,
//      y      z                                          	// a8 - af
     0131,  0130,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// b0 - b7
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//                                                        	// b8 - bf
     0377,  0377,  0377,  0377,  0377,  0377,  0377,  0377,
//             A      B      C      D      E      F      G	// c0 - c7
     0377,   017,    06,    07,   012,   013,    02,    03,
//      H      I                                          	// c8 - cf
      011,   010,  0377,  0377,  0377,  0377,  0377,  0377,
//             J      K      L      M      N      O      P	// d0 - d7
     0377,   057,   046,   047,   052,   053,   042,   043,
//      Q      R                                          	// d8 - df
      051,   050,  0377,  0377,  0377,  0377,  0377,  0377,
//                    S      T      U      V      W      X	// e0 - e7
     0377,  0377,   026,   027,   032,   033,   022,   023,
//      Y      Z                                          	// e8 - ef
      031,   030,  0377,  0377,  0377,  0377,  0377,  0377,
//      0      1      2      3      4      5      6      7	// f0 - f7
     0161,  0177,  0166,  0167,  0172,  0173,  0162,  0163,
//      8      9                                          	// f8 - ff
     0171,  0170,  0377,  0377,  0377,  0377,  0377,  0377,
};
