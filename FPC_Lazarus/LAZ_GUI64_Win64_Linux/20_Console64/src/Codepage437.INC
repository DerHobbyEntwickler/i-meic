Codepage437a : array[0..31] of Word = (


  // 00H..0FH
  $0000, // 00H = NUL
  $263A, // 01H = ☺︎
  $263B, // 02H = ☻︎
  $2665, // 03H = ♥︎
  $2666, // 04H = ♦︎
  $2663, // 05H = ♣
  $2660, // 06H = ♠
  $2022, // 07H = •
  $25D8, // 08H = ◘
  $25CB, // 09H = ○
  $25D9, // 0AH = ◙
  $2642, // 0BH = ♂︎
  $2640, // 0CH = ♀︎
  $266A, // 0DH = ♪
  $266B, // 0EH = ♫
  $263C, // 0FH = ☼



  // 10H..1FH
  $25BA, // 10H = ►
  $25C4, // 11H = ◄
  $2195, // 12H = ↕︎
  $203C, // 13H = ‼
  $00B6, // 14H = ¶
  $00A7, // 15H = §
  $25AC, // 16H = ▬
  $21A8, // 17H = ↨
  $2191, // 18H = ↑
  $2193, // 19H = ↓
  $2192, // 1AH = →
  $2190, // 1BH = ←
  $221F, // 1CH = ∟
  $2194, // 1DH = ↔
  $25B2, // 1EH = ▲
  $25BC  // 1FH = ▼



  );






Codepage437b : array[0..127] of Word = (



  // 80H..8FH
  $00C7, // 80H = Ç
  $00FC, // 81H = ü
  $00E9, // 82H = é  
  $00E2, // 83H = â
  $00E4, // 84H = ä
  $00E0, // 85H = à
  $00E5, // 86H = å
  $00E7, // 87H = ç
  $00EA, // 88H = ê
  $00EB, // 89H = ë
  $00E8, // 8AH = è
  $00EF, // 8BH = ï
  $00EE, // 8CH = î
  $00EC, // 8DH = ì
  $00C4, // 8EH = Ä
  $00C5, // 8FH = Å


  // 90H..9FH
  $00C9, // 90H = É
  $00E6, // 91H = æ
  $00C6, // 91H = Æ
  $00F4, // 91H = ô
  $00F6, // 91H = ö
  $00F2, // 91H = ò
  $00FB, // 91H = û
  $00F9, // 91H = ù
  $00FF, // 91H = ÿ
  $00D6, // 91H = Ö
  $00DC, // 91H = Ü
  $00A2, // 91H = ¢
  $00A3, // 91H = £
  $00A5, // 91H = ¥
  $20A7, // 91H = ₧
  $0192, // 91H = ƒ



  // A0H..AFH
  $00E1, // A0H = LATIN SMALL LETTER A WITH ACUTE
  $00ED, // A1H = LATIN SMALL LETTER I WITH ACUTE
  $00F3, // A2H = LATIN SMALL LETTER O WITH ACUTE
  $00FA, // A3H = LATIN SMALL LETTER U WITH ACUTE
  $00F1, // A4H = LATIN SMALL LETTER N WITH TILDE
  $00D1, // A5H = LATIN CAPITAL LETTER N WITH TILDE
  $00AA, // A6H = FEMININE ORDINAL INDICATOR
  $00BA, // A7H = MASCULINE ORDINAL INDICATOR
  $00BF, // A8H = INVERTED QUESTION MARK
  $2310, // A9H = REVERSED NOT SIGN
  $00AC, // AAH = NOT SIGN
  $00BD, // ABH = VULGAR FRACTION ONE HALF
  $00BC, // ACH = VULGAR FRACTION ONE QUARTER
  $00A1, // ADH = INVERTED EXCLAMATION MARK
  $00AB, // AEH = LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
  $00BB, // AFH = RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK 




  // B0H..BFH
  $2591, // B0H 
  $2592, // B1H
  $2593, // B2H
  $2502, // B3H
  $2524, // B4H
  $2561, // B5H
  $2562, // B6H
  $2556, // B7H
  $2555, // B8H
  $2563, // B9H
  $2551, // BAH
  $2557, // BBH
  $255D, // BCH
  $255C, // BDH
  $255B, // BEH
  $2510, // BFH




  // C0H..CFH
  $2514, // C0H 
  $2534, // C1H
  $252C, // C2H
  $251C, // C3H
  $2500, // C4H
  $253C, // C5H
  $255E, // C6H
  $255F, // C7H
  $255A, // C8H
  $2554, // C9H
  $2569, // CAH
  $2566, // CBH
  $2560, // CCH
  $2550, // CDH
  $256C, // CEH
  $2567, // CFH



  // D0H..DFH
  $2568, // D0H 
  $2564, // D1H 
  $2565, // D2H 
  $2559, // D3H 
  $2558, // D4H 
  $2552, // D5H 
  $2553, // D6H 
  $256B, // D7H 
  $256A, // D8H 
  $2518, // D9H 
  $250C, // DAH 
  $2588, // DBH 
  $2584, // DCH 
  $258C, // DDH 
  $2590, // DEH 
  $2580, // DFH 



  // E0H..EFH
  $03B1, // E0H = GREEK SMALL LETTER ALPHA
  $00DF, // E1H = LATIN SMALL LETTER SHARP S
  $0393, // E2H = GREEK CAPITAL LETTER GAMMA
  $03C0, // E3H = GREEK SMALL LETTER PI
  $03A3, // E4H = GREEK CAPITAL LETTER SIGMA
  $03C3, // E5H = GREEK SMALL LETTER SIGMA
  $00B5, // E6H = MICRO SIGN
  $03C4, // E7H = GREEK SMALL LETTER TAU
  $03A6, // E8H = GREEK CAPITAL LETTER PHI
  $0398, // E9H = GREEK CAPITAL LETTER THETA
  $03A9, // EAH = GREEK CAPITAL LETTER OMEGA
  $03B4, // EBH = GREEK SMALL LETTER DELTA
  $221e, // ECH = INFINITY
  $03C6, // EDH = GREEK SMALL LETTER PHI
  $03B5, // EEH = GREEK SMALL LETTER EPSILON
  $2229, // EFH = INTERSECTION 
     



  // F0H..FFH
  $2261, // F0H = IDENTICAL TO
  $00B1, // F1H = PLUS-MINUS SIGN
  $2265, // F2H = GREATER-THAN OR EQUAL TO
  $2264, // F3H = LESS-THAN OR EQUAL TO
  $2320, // F4H = TOP HALF INTEGRAL
  $2321, // F5H = BOTTOM HALF INTEGRAL
  $00F7, // F6H = DIVISION SIGN
  $2248, // F7H = ALMOST EQUAL TO
  $00B0, // F8H = DEGREE SIGN
  $2219, // F9H = BULLET OPERATOR
  $00B7, // FAH = MIDDLE DOT
  $221A, // FBH = SQUARE ROOT
  $207F, // FCH = SUPERSCRIPT LATIN SMALL LETTER N
  $00B2, // FDH = SUPERSCRIPT TWO
  $25A0, // FEH = BLACK SQUARE
  $00A0  // FFH = NO-BREAK SPACE 




);

