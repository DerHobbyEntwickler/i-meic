unit Language_U;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils;


const
  number_of_entries = 120;


type
  TCON_LANG = (lang_en, lang_de);
  TCON_UNIT = (unit_MainUnit_frm, unit_MainUnit_pas, unit_Unit_CONS, unit_windos);

  TLang_Array = array [unit_MainUnit_frm..unit_windos,
                       1..number_of_entries] of String;



const

{$I language_de.INC}
{$I language_en.INC}



var
  lang_var : TCON_LANG;


  function lang_text(CON_UNIT : TCON_UNIT; text_nr : Word) : String;



implementation


  function lang_text(CON_UNIT : TCON_UNIT; text_nr : Word) : String;
  begin
    case lang_var of

      lang_de : Result:=lang_array_de[CON_UNIT,text_nr];
      lang_en : Result:=lang_array_en[CON_UNIT,text_nr];

    else
      Result:=lang_array_de[CON_UNIT,text_nr];
    end;
  end; { lang_text }


end.

