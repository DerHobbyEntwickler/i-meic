unit GlobalHW_U;
{$MODE OBJFPC}


interface


uses
  pico_c,
  pico_gpio_c,
  pico_uart_c,
  pico_spi_c,
  pico_timer_c;




const

//  BAUD_RATE=115200; // ok
//  BAUD_RATE=230400; // ok
//  BAUD_RATE=460800; // ok
//  BAUD_RATE=125000; // ok

//  BAUD_RATE=500000; // ok

  BAUD_RATE=921600; // ok


VAR

  FpSPI : ^TSPI_Registers;

  Sektor_Puffer : array [0..511] of byte;


  procedure INIT_HW;

  // WAIT in Millisekunden
  PROCEDURE wait_ms(Zeit : Word);
  procedure LED_blinken;

  // UART
  procedure UART_Write_Zeichen(Zeichen : Char);
  function UART_Read_ein_Byte : Byte;
  function UART_Zeichen_lesbar : Boolean;
  procedure UART_Read_Sector;

  // SPI
  procedure SPI_Write_Byte(SPI_Byte : Byte);
  function SPI_Read_Byte : Byte;
  procedure SPI_Read_Sector;

  procedure SetBit(const SB_PicoPin : Integer);
  procedure ClearBit(const SB_PicoPin : Integer);
  procedure SetOutput(const SB_PicoPin : Integer);
  procedure SetInput(const SB_PicoPin : Integer);

  function BitHigh(const SB_PicoPin : Integer) : BOOLEAN;
  function BitLow(const SB_PicoPin : Integer) : BOOLEAN;

  procedure SetBit_CLK_80;
  procedure ClearBit_CLK_80;
  procedure SetBit_RAM_EN;
  procedure ClearBit_RAM_EN;
  procedure SetBit_RESET_80;
  procedure ClearBit_RESET_80;

  function BitLow_RD_80 : BOOLEAN;
  function BitHigh_RD_80 : BOOLEAN;
  function BitLow_WR_80 : BOOLEAN;
  function BitHigh_WR_80 : BOOLEAN;
  function BitHigh_IOM_80 : BOOLEAN;

  procedure Datenbus_auf_Eingang;
  procedure Datenbus_auf_Ausgang;
  procedure Schreibe_Datenbus(DB_Byte : Byte);
  function Lese_Datenbus : Byte;


  // ITP3
  procedure ITP3_Daten_auf_Eingang;
  procedure ITP3_Daten_auf_Ausgang;



implementation





  // ******************************
  // ***    Hilfssprogramme     ***
  // ******************************



  // WAIT in Millisekunden
  PROCEDURE wait_ms(Zeit : Word);
  BEGIN
    busy_wait_us_32(Zeit*1000);
  END;






  procedure LED_blinken;
  begin

    // DS0
    gpio_init(TPicoPin.ITP3_DS0);
    SetOutput(TPicoPin.ITP3_DS0);

    // DS1
    gpio_init(TPicoPin.ITP3_DS1);
    SetOutput(TPicoPin.ITP3_DS1);

    // DS2
    gpio_init(TPicoPin.ITP3_DS2);
    SetOutput(TPicoPin.ITP3_DS2);

    // DS3
    gpio_init(TPicoPin.ITP3_DS3);
    SetOutput(TPicoPin.ITP3_DS3);


    while true do begin

      SetBit(TPicoPin.ITP3_DS0);
      SetBit(TPicoPin.ITP3_DS1);
      SetBit(TPicoPin.ITP3_DS2);
      SetBit(TPicoPin.ITP3_DS3);

      wait_ms(300);

      ClearBit(TPicoPin.ITP3_DS0);
      ClearBit(TPicoPin.ITP3_DS1);
      ClearBit(TPicoPin.ITP3_DS2);
      ClearBit(TPicoPin.ITP3_DS3);

      wait_ms(300);

    end;

  end; // LED_blinken;






  { ** READ-Programme ** }



  function UART_Zeichen_lesbar : Boolean;
  begin
    Result:=uart_is_readable(uart)
  end; // UART_Read_Zeichen





  function UART_Read_Zeichen : Char;
  begin
    Result:=uart_getc(uart)
  end; // UART_Read_Zeichen




  function UART_Read_ein_Byte : Byte;
  begin
    Result:=Byte(uart_getc(uart))
  end; // UART_Read_Byte



  procedure UART_Read_Sector;
  begin
    uart_read_blocking(uart,Sektor_Puffer,512);
  end; // UART_Read_Sector





  { ** WRITE-Programme ** }

  procedure UART_Write_Zeichen(Zeichen : Char);
  begin
    uart_puts(uart, Zeichen);
  end; // UART_Write_Zeichen









  // *********************************
  // ***    FLASH Read (Lesen)     ***
  // *********************************




  // schreibt das SPI_Byte in das LCD
  procedure SPI_Write_Byte(SPI_Byte : Byte);
  var
    data : array[0..0] of byte;
  begin

    data[0] := SPI_Byte;
    spi_write_blocking(FpSPI^,data,1);

  end; // procedure SPI_Write_Byte







  // schreibt das SPI_Byte in das LCD
  function SPI_Read_Byte : Byte;
  var
    data : array[0..0] of byte;
  begin
    spi_read_blocking(FpSPI^,0,data,1);
    Result:=data[0];
  end; // SPI_Read_Byte






  // schreibt das SPI_Byte in das LCD
  procedure SPI_Read_Sector;
  begin
    spi_read_blocking(FpSPI^,0,Sektor_Puffer,512);
  end; // SPI_Read_Sector





  // *****************************************************
  //            Hardware - GPIO
  // *****************************************************



  procedure SetBit(const SB_PicoPin : Integer);
  begin
    gpio_put(SB_PicoPin,true);
  end; // SetBit



  procedure ClearBit(const SB_PicoPin : Integer);
  begin
    gpio_put(SB_PicoPin,false);
  end; // ClearBit



  procedure SetOutput(const SB_PicoPin : Integer);
  begin
    gpio_set_dir(SB_PicoPin,TGPIODirection.GPIO_OUT);
  end; // SetOutput



  procedure SetInput(const SB_PicoPin : Integer);
  begin
    gpio_set_dir(SB_PicoPin,TGPIODirection.GPIO_IN);
  end; // SetInput





  function BitHigh(const SB_PicoPin : Integer) : BOOLEAN;
  begin
    RESULT:=gpio_get(SB_PicoPin);
  end; // BitHigh



  function BitLow(const SB_PicoPin : Integer) : BOOLEAN;
  begin
    RESULT:=not gpio_get(SB_PicoPin);
  end; // BitLow






  // SetBit(TPicoPin.CLK_80);
  procedure SetBit_CLK_80;
  begin
    gpio_put(TPicoPin.CLK_80,true);
  end; // SetBit_CLK_80


  procedure ClearBit_CLK_80;
  begin
    gpio_put(TPicoPin.CLK_80,false);
  end; // SetBit_CLK_80


  // SetBit(TPicoPin.RAM_EN);
  procedure SetBit_RAM_EN;
  begin
    gpio_put(TPicoPin.RAM_EN,true);
  end; // SetBit_RAM_EN


  // ClearBit(TPicoPin.RAM_EN);
  procedure ClearBit_RAM_EN;
  begin
    gpio_put(TPicoPin.RAM_EN,false);
  end; // SetBit_RAM_EN



  // SetBit(TPicoPin.RESET_80);
  procedure SetBit_RESET_80;
  begin
    gpio_put(TPicoPin.RESET_80,true);
  end; // SetBit_RESET_80


  // ClearBit(TPicoPin.RESET_80);
  procedure ClearBit_RESET_80;
  begin
    gpio_put(TPicoPin.RESET_80,false);
  end; // SetBit_RESET_80






  // BitLow(TPicoPin.RD_80)
  function BitLow_RD_80 : BOOLEAN;
  begin

    if gpio_get(TPicoPin.RD_80) then
      RESULT:=FALSE
    else
      RESULT:=TRUE;

  end; // BitLow_RD_80


  // BitHigh(TPicoPin.RD_80)
  function BitHigh_RD_80 : BOOLEAN;
  begin

    if gpio_get(TPicoPin.RD_80) then
      RESULT:=TRUE
    else
      RESULT:=FALSE;

  end; // BitHigh_RD_80



  // BitLow(TPicoPin.WR_80)
  function BitLow_WR_80 : BOOLEAN;
  begin

    if gpio_get(TPicoPin.WR_80) then
      RESULT:=FALSE
    else
      RESULT:=TRUE;

  end; // BitLow_WR_80


  // BitHigh(TPicoPin.WR_80)
  function BitHigh_WR_80 : BOOLEAN;
  begin

    if gpio_get(TPicoPin.WR_80) then
      RESULT:=TRUE
    else
      RESULT:=FALSE;

  end; // BitHigh_WR_80



  // BitHigh(TPicoPin.IOM_80)
  function BitHigh_IOM_80 : BOOLEAN;
  begin

    if gpio_get(TPicoPin.IOM_80) then
      RESULT:=TRUE
    else
      RESULT:=FALSE;

  end; // BitHigh_IOM_80








  // ***************************
  // * PICO-PINs fuer CPU8088  *
  // ***************************


  procedure Datenbus_auf_Eingang;
  begin

    SetInput(TPicoPin.D0_80);
    SetInput(TPicoPin.D1_80);
    SetInput(TPicoPin.D2_80);
    SetInput(TPicoPin.D3_80);
    SetInput(TPicoPin.D4_80);
    SetInput(TPicoPin.D5_80);
    SetInput(TPicoPin.D6_80);
    SetInput(TPicoPin.D7_80);

  end; // Datenbus_auf_Eingang




  procedure Datenbus_auf_Ausgang;
  begin

    SetOutput(TPicoPin.D0_80);
    SetOutput(TPicoPin.D1_80);
    SetOutput(TPicoPin.D2_80);
    SetOutput(TPicoPin.D3_80);
    SetOutput(TPicoPin.D4_80);
    SetOutput(TPicoPin.D5_80);
    SetOutput(TPicoPin.D6_80);
    SetOutput(TPicoPin.D7_80);

  end; // Datenbus_auf_Ausgang




  function Lese_Datenbus : Byte;
  var
    Ergebnis : Byte;
  begin

    Ergebnis:=%00000000;

    // D0 einlesen
    if BitHigh(TPicoPin.D0_80) then
      Ergebnis:=Ergebnis or %00000001;

    // D1 einlesen
    if BitHigh(TPicoPin.D1_80) then
      Ergebnis:=Ergebnis or %00000010;

    // D2 einlesen
    if BitHigh(TPicoPin.D2_80) then
      Ergebnis:=Ergebnis or %00000100;

    // D3 einlesen
    if BitHigh(TPicoPin.D3_80) then
      Ergebnis:=Ergebnis or %00001000;

    // D4 einlesen
    if BitHigh(TPicoPin.D4_80) then
      Ergebnis:=Ergebnis or %00010000;

    // D5 einlesen
    if BitHigh(TPicoPin.D5_80) then
      Ergebnis:=Ergebnis or %00100000;

    // D6 einlesen
    if BitHigh(TPicoPin.D6_80) then
      Ergebnis:=Ergebnis or %01000000;

    // D7 einlesen
    if BitHigh(TPicoPin.D7_80) then
      Ergebnis:=Ergebnis or %10000000;

    //  Warten_auf_Tastendruck;

    Result:=Ergebnis;
  end; // Lese_Datenbus





  procedure Schreibe_Datenbus(DB_Byte : Byte);
  var
    b1 : Byte;
  begin

    b1:=DB_Byte and %00000001;

    // D0 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D0_80)
    else
      SetBit(TPicoPin.D0_80);


    b1:=DB_Byte and %00000010;

    // D1 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D1_80)
    else
      SetBit(TPicoPin.D1_80);


    b1:=DB_Byte and %00000100;

    // D2 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D2_80)
    else
      SetBit(TPicoPin.D2_80);


    b1:=DB_Byte and %00001000;

    // D3 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D3_80)
    else
      SetBit(TPicoPin.D3_80);


    b1:=DB_Byte and %00010000;

    // D4 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D4_80)
    else
      SetBit(TPicoPin.D4_80);


    b1:=DB_Byte and %00100000;

    // D5 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D5_80)
    else
      SetBit(TPicoPin.D5_80);


    b1:=DB_Byte and %01000000;

    // D6 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D6_80)
    else
      SetBit(TPicoPin.D6_80);


    b1:=DB_Byte and %10000000;


    // D7 ausgeben
    if b1=0 then
      ClearBit(TPicoPin.D7_80)
    else
      SetBit(TPicoPin.D7_80);


  end; // Schreibe_Datenbus






  // ********************
  // ***   ITP3   ***
  // ********************


  procedure ITP3_Daten_auf_Ausgang;
  begin
    SetOutput(TPicoPin.ITP3_D0);
    SetOutput(TPicoPin.ITP3_D1);
    SetOutput(TPicoPin.ITP3_D2);
    SetOutput(TPicoPin.ITP3_D3);
  end; // ITP3_Daten_auf_Eingang



  procedure ITP3_Daten_auf_Eingang;
  begin
    SetInput(TPicoPin.ITP3_D0);
    SetInput(TPicoPin.ITP3_D1);
    SetInput(TPicoPin.ITP3_D2);
    SetInput(TPicoPin.ITP3_D3);
  end; // ITP3_Daten_auf_Ausgang









  procedure INIT_HW;
  begin



    // 0. INIT-PORTS-RP2040

    // GP0 = UART_TX
    // GP1 = UART_RX
    // INIT-Serial
     uart_init(uart, BAUD_RATE);
     gpio_set_function(TPicoPin.UART_TX, TGPIOFunction.GPIO_FUNC_UART);
     gpio_set_function(TPicoPin.UART_RX, TGPIOFunction.GPIO_FUNC_UART);

    // GP2 = ITP3_DS2
    gpio_init(TPicoPin.ITP3_DS2);
    SetOutput(TPicoPin.ITP3_DS2);
    SetBit(TPicoPin.ITP3_DS2);
    gpio_pull_up(TPicoPin.ITP3_DS2);

    // GP3 = ITP3_DS3
    gpio_init(TPicoPin.ITP3_DS3);
    SetOutput(TPicoPin.ITP3_DS3);
    SetBit(TPicoPin.ITP3_DS3);
    gpio_pull_up(TPicoPin.ITP3_DS3);

    // GP4 = ITP3_D3
    gpio_init(TPicoPin.ITP3_D3);
    SetInput(TPicoPin.ITP3_D3);

    // GP5 = RESET_80 - Ausgang und Low (InAktiv)
    gpio_init(TPicoPin.RESET_80);
    SetOutput(TPicoPin.RESET_80);
    ClearBit(TPicoPin.RESET_80);

    // GP6 = D0_80 - Eingang
    gpio_init(TPicoPin.D0_80);

    // GP7 = D1_80 - Eingang
    gpio_init(TPicoPin.D1_80);

    // GP8 = D2_80 - Eingang
    gpio_init(TPicoPin.D2_80);

    // GP9 = D3_80 - Eingang
    gpio_init(TPicoPin.D3_80);

    // GP10 = D4_80 - Eingang
    gpio_init(TPicoPin.D4_80);

    // GP11 = D5_80 - Eingang
    gpio_init(TPicoPin.D5_80);

    // GP12 = D6_80 - Eingang
    gpio_init(TPicoPin.D6_80);

    // GP13 = D7_80 - Eingang
    gpio_init(TPicoPin.D7_80);

    // GP14 = ITP3_D0
    gpio_init(TPicoPin.ITP3_D0);
    SetInput(TPicoPin.ITP3_D0);

    // GP15 = ITP3_D1
    gpio_init(TPicoPin.ITP3_D1);
    SetInput(TPicoPin.ITP3_D1);

    // GP16 = ITP3_D2
    gpio_init(TPicoPin.ITP3_D2);
    SetInput(TPicoPin.ITP3_D2);

    // GP17 = kein Anschluss
    // GP18 = nicht genutzt
    // GP19 = kein Anschluss

    // GP20 = ITP3_DR
    gpio_init(TPicoPin.ITP3_DR);
    SetInput(TPicoPin.ITP3_DR);
    gpio_pull_up(TPicoPin.ITP3_DR);

    // GP21 = ITP3_DS0
    gpio_init(TPicoPin.ITP3_DS0);
    SetOutput(TPicoPin.ITP3_DS0);
    SetBit(TPicoPin.ITP3_DS0);
    gpio_pull_up(TPicoPin.ITP3_DS0);

    // GP22 = ITP3_DS1
    gpio_init(TPicoPin.ITP3_DS1);
    SetOutput(TPicoPin.ITP3_DS1);
    SetBit(TPicoPin.ITP3_DS1);
    gpio_pull_up(TPicoPin.ITP3_DS1);

    // GP23 = CLK_80 - Ausgang und Low (InAktiv)
    gpio_init(TPicoPin.CLK_80);
    SetOutput(TPicoPin.CLK_80);
    ClearBit(TPicoPin.CLK_80);

    // GP24 = nicht genutzt

    // GP25 = NMI_80 - Ausgang und Low (InAktiv)
    gpio_init(TPicoPin.NMI_80);
    SetOutput(TPicoPin.NMI_80);
    ClearBit(TPicoPin.NMI_80);

    // GP26 = RAM_EN - Ausgang und High (InAktiv)
    gpio_init(TPicoPin.RAM_EN);
    SetOutput(TPicoPin.RAM_EN);
    SetBit(TPicoPin.RAM_EN);

    // GP27 = IOM_80 - Eingang
    gpio_init(TPicoPin.IOM_80);
    SetInput(TPicoPin.IOM_80);

    // GP28 = RD_80 - Eingang
    gpio_init(TPicoPin.RD_80);
    SetInput(TPicoPin.RD_80);

    // GP29 = WR_80 - Eingang
    gpio_init(TPicoPin.WR_80);
    SetInput(TPicoPin.WR_80);




   // INIT-Sektor_Puffer
 //  SetLength(Sektor_Puffer,512);


   // Datenbus auf Eingang
   Datenbus_auf_Eingang;



  end; // procedure INIT_HW







end. // GlobalHW_U


