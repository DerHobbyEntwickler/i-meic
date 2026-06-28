
lang_array_de : TLang_Array =(

{ unit_MainUnit_frm }
(
{ 001 } 'Verbinden',
{ 002 } 'Port:',
{ 003 } 'Baudrate:',
{ 004 } 'Schliessen',
{ 005 } 'LOG-Meldungen löschen',
{ 006 } 'LOG-Meldungen speichern',
{ 007 } 'Monitor (VIDEO)',
{ 008 } 'Geräte-'#13#10'verwal-'#13#10'tung',
{ 009 } 'Tastatur (CONIN)',
{ 010 } 'Drucker (PRINT)',
{ 011 } 'Audio (SOUND)',
{ 012 } 'Floppy (FDD)',
{ 013 } 'Festplatte (HDD)',
{ 014 } 'Uhr (RTC)',
{ 015 } 'Mouse (Maus)',
{ 016 } 'Drive',
{ 017 } 'Laufwerke speichern',
{ 018 } 'Debug',
{ 019 } '',
{ 020 } 'Schriftgroesse Monitor',
{ 021 } 'LOG_Monitor',
{ 022 } 'LOG_Monitor speichern',
{ 023 } 'Liste der installierten Fonts',
{ 024 } 'Font übernehmen',
{ 025 } 'Einstellungen',
{ 026 } '  Print speichern',
{ 027 } 'sende XOFF nach Reset',
{ 028 } 'LOG CONIN',
{ 029 } 'LOG CONOUT',
{ 030 } 'LOG READ',
{ 031 } 'LOG WRITE',
{ 032 } 'LOG DEBUG',
{ 033 } 'LOG MOUSE',
{ 034 } 'Laufwerke',
{ 035 } 'Image:',
{ 036 } 'Sprache',
{ 037 } 'Deutsch',
{ 038 } 'Englisch',
{ 039 } 'Auswahl der Sprache',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', ''),

{ unit_MainUnit_pas }
(
{ procedure TForm_Console.Port_Connect }
{ 001 } '*** Fehler: kein Port ausgewaehlt',
{ 002 } 'Trennen',
{ 003 } 'Verbinden',
{ 004 } '--- Port wurde getrennt',
{  }
{ 005 } '>> RESET von der Hardware empfangen',
{ 006 } '>> XOFF gesendet ...',
{ 007 } '*** Fehler: kein Command_Char in der Befehlszeile ***',
{ 008 } '*** LOG-Datei=ListBox_Messages.txt gespeichert ***',
{ 009 } '*** Datenpuffer fuer serielle Schnittstelle (ReadCOM) geloescht ***',
{ 010 } 'Laufwerke wurden gesichert ...',
{ 011 } ' ist verbunden mit einer Baudrate von ',
{ procedure TForm_Console.send_Date_and_Time }
{ 012 } '<< Datum und Zeit gesendet (',
{ procedure TForm_Console.send_CONIN }
{ 013 } '<< CONIN gesendet (',
{ procedure TForm_Console.send_MOUSE(SM_Param : Char) }
{ 014 } '*** Fehler Maus Parameter <',
{ 015 } '> nicht bekannt ***',
{ procedure TForm_Console.send_VIDEO_GET_Parameter(DB_Routine : Byte) }
{ 016 } '*** Fehler in send_VIDEO_GET_Parameter: DB_Routine=',
{ 017 } 'H nicht definiert ***',
{ 018 } '*** Fehler: zu viele Parameter in den Daten (',
{ 019 } '>> Fehler Nr: ',
{ 020 } ' vom Mikrocontroller gesendet',
{ 021 } '*** Fehler: das Kommando:',
{ 022 } ') ist nicht definiert ***',
{ 023 } '*** Fehler: ReadCOM=<',
 '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', ''),

{ unit_Unit_CONS }
(
{ Video_Send.INC }
{ procedure Special_Character_to_Matrix }
{ 001 } ' nicht aufgeloest',
{ 002 } '*** Fehler in Video_Send_Routine: DB_Routine=',
{ 003 } 'H nicht definiert ***',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),

{ unit_windos }
(
{ constructor Twdos.Create }
{ 001 } '*** FDD-Ordner(',
{ 002 } ') wurde angelegt ***',
{ 003 } ') konnte nicht angelegt werden ***',
{ 004 } '*** HDD-Ordner(',
{ 005 } 'DOS-Laufwerk ',
{ 006 } ' geladen...',
{ 007 } 'kein Image',
{ 008 } '*** DOS-Laufwerk ',
{ 009 } ' konnte nicht geladen werden ***',
 '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '')

);




