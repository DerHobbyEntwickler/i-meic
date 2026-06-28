
lang_array_en : TLang_Array =(

{ unit_MainUnit_frm }
(
{ 001 } 'Connect',
{ 002 } 'Port:',
{ 003 } 'Baudrate:',
{ 004 } 'Close',
{ 005 } 'Delete log messages',
{ 006 } 'Save log messages',
{ 007 } 'Monitor (VIDEO)',
{ 008 } 'Device'#13#10'Manage-'#13#10'ment',
{ 009 } 'Keyboard (CONIN)',
{ 010 } 'Printer (PRINT)',
{ 011 } 'Audio (SOUND)',
{ 012 } 'Floppy (FDD)',
{ 013 } 'Harddrive (HDD)',
{ 014 } 'Clock (RTC)',
{ 015 } 'Mouse (Mouse)',
{ 016 } 'Drive',
{ 017 } 'Save drives',
{ 018 } 'Debug',
{ 019 } '',
{ 020 } 'Monitor font size',
{ 021 } 'LOG_Monitor',
{ 022 } 'Save LOG_Monitor',
{ 023 } 'List of installed fonts',
{ 024 } 'Apply font',
{ 025 } 'Settings',
{ 026 } '  Save printout',
{ 027 } 'send XOFF after reset',
{ 028 } 'LOG CONIN',
{ 029 } 'LOG CONOUT',
{ 030 } 'LOG READ',
{ 031 } 'LOG WRITE',
{ 032 } 'LOG DEBUG',
{ 033 } 'LOG MOUSE',
{ 034 } 'Drives',
{ 035 } 'Image:',
{ 036 } 'Language',
{ 037 } 'German',
{ 038 } 'English',
{ 039 } 'Language selection',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', ''),

{ unit_MainUnit_pas }
(
{ procedure TForm_Console.Port_Connect }
{ 001 } '*** Error: no port selected',
{ 002 } 'Disconnect',
{ 003 } 'Connect',
{ 004 } '--- Port was disconnected',
{  }
{ 005 } '>> RESET received from the hardware',
{ 006 } '>> XOFF sent ...',
{ 007 } '*** Error: no Command_Char in the command line ***',
{ 008 } '*** LOG file=ListBox_Messages.txt saved ***',
{ 009 } '*** Data buffer for serial interface (ReadCOM) cleared ***',
{ 010 } 'Drives have been backed up ...',
{ 011 } ' is connected with a baudrate of ',
{ procedure TForm_Console.send_Date_and_Time }
{ 012 } '<< Date and time sent (',
{ procedure TForm_Console.send_CONIN }
{ 013 } '<< CONIN sent (',
{ procedure TForm_Console.send_MOUSE(SM_Param : Char) }
{ 014 } '*** Mouse parameter error <',
{ 015 } '> not known ***',
{ procedure TForm_Console.send_VIDEO_GET_Parameter(DB_Routine : Byte) }
{ 016 } '*** Error in send_VIDEO_GET_Parameter: DB_Routine=',
{ 017 } 'H undefined ***',
{ 018 } '*** Error: too many parameters in the data (',
{ 019 } '>> Error No.: ',
{ 020 } ' sent by the microcontroller',
{ 021 } '*** Error: the command:',
{ 022 } ') is not defined ***',
{ 023 } '*** Error: ReadCOM=<',
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
{ 001 } ' not resolved',
{ 002 } '*** Error in Video_Send_Routine: DB_Routine=',
{ 003 } 'H undefined ***',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''),

{ unit_windos }
(
{ constructor Twdos.Create }
{ 001 } '*** FDD folder(',
{ 002 } ') was created ***',
{ 003 } ') could not be created ***',
{ 004 } '*** HDD folder(',
{ 005 } 'DOS drive ',
{ 006 } ' loaded ...',
{ 007 } 'no Image',
{ 008 } '*** DOS drive ',
{ 009 } ' could not be loaded ***',
 '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
 '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '')

);




