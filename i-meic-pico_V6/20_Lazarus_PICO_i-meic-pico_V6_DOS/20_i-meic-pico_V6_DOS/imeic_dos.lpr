program imeic_dos;
{$MODE OBJFPC}
{$MEMORY 10000,10000}



uses
  pico_gpio_c,

  GlobalDEF_U,
  GlobalHW_U,
  UART_U,
  BIOSAdmin_U,
  DeviceManager_U,
  ITP3_SRV_U;



const
  CLK_mask = longWord(1 shl 23);


label
  MyLabel;




// **************************************



begin

  // Initialisierung der gesammten Hardware
  INIT_HW;


  INIT_GlobalDEF;



  // lade das BIOS vom Flash des
  // ProMicro in den SRAM
  load_BootJMP_and_BIOS_into_SRAM;




  // Initialisieren und Abfrage ob vorhanden,
  // wenn ja, WHO_ARE_YOU Abfrage ueber DEVICE_VECTOR
  INIT_Serial;




  // Abfrage und Einlesen der ITP3-Anschlüsse
  ITP3_pruefe_Anschluesse;





  // Lesen oder Neubeschreiben des BIOS-FLASH
  INIT_BIOS_FLASH;


  // Kontrolle, ob alle notwendigen Geraete
  // vorhanden sind (ansonsten Fehlermeldung)
  DEVICE_CONTROL;




// Starten der BIOS-Routinen

// ********************
// *** Taktschleife ***
// ********************





// while true do begin
asm
MyLabel:
end;


// SetBit(TPicoPin.CLK_80);
// gpio_set_mask(1 shl 23);
// gpio_set_mask(%00000000100000000000000000000000);
  gpio_set_mask(1 shl TPicoPin.CLK_80);



// ClearBit(TPicoPin.CLK_80);
// gpio_clr_mask(1 shl 23);
// gpio_clr_mask(%00000000100000000000000000000000);
  gpio_clr_mask(1 shl TPicoPin.CLK_80);


// if gpio_get(TPicoPin.IOM_80) then
// if ((sio.gpio_in and (1 shl 27)) <> 0) then
// if ((sio.gpio_in and (%00001000000000000000000000000000)) <> 0) then
if ((sio.gpio_in and (1 shl TPicoPin.IOM_80)) <> 0) then
  Analyze_IO;


// end; // while true do
asm
   b MyLabel
end;



end. // RONBIOS
