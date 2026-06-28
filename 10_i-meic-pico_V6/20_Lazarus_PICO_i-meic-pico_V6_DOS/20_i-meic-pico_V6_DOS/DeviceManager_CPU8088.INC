

  // **************************
  // * CPU8088 Hilfsprogramme *
  // **************************





  // ASM-Code ist schneller !!!
  procedure send_one_clock_cycle;
  begin

    SetBit_CLK_80;
    ClearBit_CLK_80;

  end; // send_one_clock_cycle






  procedure send_number_of_CLK(number_of_CLK : Word);
  var
    counter : Word;
  begin

    for counter:=1 to number_of_CLK do begin
      send_one_clock_cycle;
    end;

  end; // sende_Takte;






  procedure wait_until_RD_LOW;
  begin

    // warten solange /RD aktiv ist
    while BitLow_RD_80 do begin
      send_one_clock_cycle;
    end; // while BitLow(RD_80_E) do

  end; // wait_until_RD_LOW









procedure Write_byte_to_data_bus(DB_Byte : Byte);
begin


  // Abschalten des SRAM, da nur die CPU
  // angesprochen werden soll
  SetBit_RAM_EN;

  // der Datenbus ist nun hochohmig

  // Datenbus vom PICO aus
  // auf Ausgang schalten
  Datenbus_auf_Ausgang; // (Fuesse runter)

  // und Ausgabe des Inhalzs von Temp_A_Byte
  // auf den Datenbus
  Schreibe_Datenbus(DB_Byte);

  // weiterschalten auf T3
  wait_until_RD_LOW; // warten bis Lesebefehl beedet ist

  // Datenbus vom PICO aus
  // auf Eingang schalten (Fuesse hoch)
  Datenbus_auf_Eingang;

  // wieder aktivieren der SRAM
  // Leitung
  ClearBit_RAM_EN;

end; // Write_byte_to_data_bus









procedure RESET_pulse_to_CPU8088;
begin

  SetBit_RESET_80;
  send_number_of_CLK(100);
  ClearBit_RESET_80;

end; // RESET_pulse_to_CPU8088






procedure wait_until_RD_goes_LOW;
begin

  // warten bis /RD aktiv wird (Low)
  while BitHigh_RD_80 do begin
    send_one_clock_cycle;
  end; // while BitHigh(TPicoPin.RD_80) do

end; // wait_until_RD_goes_LOW







procedure wait_until_WR_LOW;
begin

  // warten solange /WR aktiv ist
  while BitLow_WR_80 do begin
    send_one_clock_cycle;
  end; // while BitLow(TPicoPin.WR_80) do

end; // wait_until_WR_LOW;






procedure wait_until_WR_HIGH;
begin

  // warten solange /WR inaktiv ist
  while BitHigh_WR_80 do begin
    send_one_clock_cycle;
  end; // while BitHigh(TPicoPin.WR_80) do

end; // wait_until_WR_HIGH





// RD=LOW, IO=HIGH -> Lesen von IO
// wartet solange, bis IO_RD aktiv wird (LOW)
procedure wait_until_IO_RD_goes_LOW;
var
  IO_RD_Schleife : Boolean;
begin

  IO_RD_Schleife:=true;

  // warten bis /RD aktiv wird (Low)
  while IO_RD_Schleife do begin

    send_one_clock_cycle;

    if BitLow_RD_80 then begin

      if BitHigh_IOM_80 then begin
        IO_RD_Schleife:=false;
      end; // if BitHigh(TPicoPin.IOM_80) then

    end; // if BitLow(TPicoPin.RD_80) then

  end; // while IO_RD_Schleife do

end; // procedure warte_bis_IO_RD_LOW_wird






// WR=LOW, IO=HIGH -> Schreiben auf IO
// wartet solange, bis IO_WR aktiv wird (LOW)
procedure wait_until_IO_WR_goes_LOW;
var
  IO_WR_Schleife : Boolean;
begin

  IO_WR_Schleife:=true;

  // warten bis /WR aktiv wird (Low)
  while IO_WR_Schleife do begin

    send_one_clock_cycle;

    if BitLow_WR_80 then begin

      if BitHigh_IOM_80 then begin
        IO_WR_Schleife:=false;
      end;

    end; // if BitLow(TPicoPin.WR_80) then

  end; // while IO_WR_Schleife do

end; // procedure wait_until_IO_WR_goes_LOW





function Read_Byte_from_Databus : Byte;
var
  Ergebnis : Byte;
begin

  wait_until_WR_HIGH; // warten bis Schreibbefehl beginnt

//  sende_einen_Takt;

  Ergebnis:=Lese_Datenbus;

  wait_until_WR_LOW; // warten solange Schreibbefehl aktiv

  Result:=Ergebnis;

end; // Read_Byte_from_Databus








procedure ein_Byte_in_CPU8088(OP_DATA_Byte : Byte);

begin
//void FeedOneByte(byte data)
// "Feed" one byte to the V20 CPU.
//
// Wait for a Read Bus Cycle and force a byte on the Data Bus putting the SRAM in HiZ.
// It is assumed here a Memory Read Bus Cycles (no check is done on IOM_).
// For more info about the V20 bus timing see the uPD70108H datasheet.
//

  wait_until_RD_goes_LOW;

  Write_byte_to_data_bus(OP_DATA_Byte);

end; // ein_Byte_in_CPU8088;





function ein_Byte_von_CPU8088 : Byte;
var
  Ergebnis : Byte;

begin

  Ergebnis:=Read_Byte_from_Databus;

  wait_until_WR_LOW;

  Result:=Ergebnis;

end; // ein_Byte_von_CPU8088








procedure write_a_byte_to_SRAM(Byte_in_SRAM_Daten : Byte;
                               Byte_in_SRAM_Offset : Word);
var
  ein_Byte_Offset : Byte;
 // Byte_in_SRAM_Daten : Byte;
begin

// Wie wird das gemacht?
//   ; MOV_MEM_IMM_OPCODE    0xC606
//   C606785612    mov   [5678H], byte 12H

  // 1. Operations-Code C6H + 06H fuer: MOV m8,imm8
  ein_Byte_in_CPU8088($C6);
  ein_Byte_in_CPU8088($06);

  ein_Byte_Offset:=LO(Byte_in_SRAM_Offset);
  ein_Byte_in_CPU8088(ein_Byte_Offset);
  ein_Byte_Offset:=HI(Byte_in_SRAM_Offset);
  ein_Byte_in_CPU8088(ein_Byte_Offset);

  ein_Byte_in_CPU8088(Byte_in_SRAM_Daten);

end; // write_a_byte_to_SRAM








procedure RESET_CPU8088;
begin

  RESET_pulse_to_CPU8088;

//  Byte_in_SRAM_Offset:=$0000;
  write_a_byte_to_SRAM($00,$0000);

end; // RESET_CPU8088;







procedure load_DS(DS_Offset : Word);
var
  DS_Byte : Byte;
begin

// ; MOV_AX_IMM_OPCODE     0xB8
// B84523     mov   ax, 2345H

  ein_Byte_in_CPU8088($B8);

//  DS_Byte:=$81; // Low(DS_Offset);
  DS_Byte:=LO(DS_Offset);

  ein_Byte_in_CPU8088(DS_Byte);

//  DS_Byte:=$46; // High(DS_Offset);
  DS_Byte:=HI(DS_Offset);
  ein_Byte_in_CPU8088(DS_Byte);

// ; MOV_DS_AX_OPCODE      0x8ED8
// 8ED8     mov    ds, ax

  ein_Byte_in_CPU8088($8E);
  ein_Byte_in_CPU8088($D8);

end; // load_DS





// Die CPU 8088 laedt nach dem RESET die Speicherzellen ab
// FFFF:0000 aus und startet die Abarbeitung mit
// diesem CODE
procedure load_BootJMP_into_SRAM;
begin

  RESET_pulse_to_CPU8088;

  load_DS($FFFF);


// ; JMP_FAR_OPCODE           0xEA
// EA5BE000F0     jmp   F000H:E05BH
// EA78563412     jmp   1234H:5678H

  // F000:FFF0: Power-On Entry Point
  // JMP (FAR) OP-Code
  write_a_byte_to_SRAM($EA,$0000); // EAH

  // FFFF:0001
  write_a_byte_to_SRAM($5B,$0001); // 5BH

  // FFFF:0002
  write_a_byte_to_SRAM($00,$0002); // 00

  // FFFF:0003
  write_a_byte_to_SRAM($00,$0003); // 00

  // FFFF:0004
  write_a_byte_to_SRAM(BIOS_Seg_Byte,$0004); // BIOS_Seg_Byte



  // F000:FFF5: ROM Date in ASCII format

  // FFFF:0005
  write_a_byte_to_SRAM($30,$0005); // 0

  // FFFF:0006
  write_a_byte_to_SRAM($31,$0006); // 1

  // FFFF:0007
  write_a_byte_to_SRAM($2F,$0007); // "/"

  // FFFF:0008
  write_a_byte_to_SRAM($30,$0008); // 0

  // FFFF:0009
  write_a_byte_to_SRAM($31,$0009); // 1

  // FFFF:000A
  write_a_byte_to_SRAM($2F,$000A); // "/"

  // FFFF:000B
  write_a_byte_to_SRAM($39,$000B); // 9

  // FFFF:000C
  write_a_byte_to_SRAM($32,$000C); // 2

  // FFFF:000D
  write_a_byte_to_SRAM($00,$000D);



  // FFFF:000E
  // F000:FFFE: System Model identification (0xFC for AT, 0xFE for XT)
  write_a_byte_to_SRAM($FE,$000E);

  // FFFF:000F
  write_a_byte_to_SRAM($55,$000F);


end; // load_BootJMP_into_SRAM






procedure load_BIOS_into_SRAM;
var
  BIOS_ARR_Pos, SRAM_Offset : Word;
begin

  load_DS(BIOS_Segment);

  SRAM_Offset:=$0000;

  for BIOS_ARR_Pos:=0 to Laenge_BIOS_Array do begin

    write_a_byte_to_SRAM(BIOS_ARR[BIOS_ARR_Pos],SRAM_Offset);
    INC(SRAM_Offset);

  end;

end; // load_BIOS_into_SRAM






procedure load_BootJMP_and_BIOS_into_SRAM;
begin

  RESET_CPU8088;

  load_BootJMP_into_SRAM;

  load_BIOS_into_SRAM;

  RESET_pulse_to_CPU8088;

end; // load_BootJMP_and_BIOS_into_SRAM










