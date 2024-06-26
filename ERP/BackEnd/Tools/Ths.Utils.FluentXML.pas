﻿{-------------------------------------------------------------------------------
-  Author      : Uğur PARLAYAN                                                 -
-  Email       : ugurparlayan@gmail.com                                        -
-  Class Name  : TFluentXML Generator.                                         -
-  Description : This unit demonstrates how we can produce an XML document     -
-                in Object Pascal (Delphi) with a simple way of using          -
-                the Fluent Design pattern and is offered to                   -
-                community service for this purpose.                           -
-  Create Date : 2017-09-12                                                    -
-  License     : GPL-3.0                                                       -
-  Copyright (C) 2017 Uğur PARLAYAN                                            -
-------------------------------------------------------------------------------}
unit Ths.Utils.FluentXML;

interface

uses
  System.SysUtils, System.StrUtils, System.Variants, System.Classes, Vcl.Dialogs;

type
  TFluentXML = class
    type
      TVarArray = array of Variant;
      TVarArrayHelper = record helper for TVarArray
        function Split(aDelimiter: String): String;
      end;
      TEncodingHelper = class Helper for TEncoding
        function AsEncoderName: String;
      end;
    private
      _Version    : Double;
      _Encoding   : TEncoding;
      _NameSpace  : string;
      _Source     : String;
    strict private
      function _if(aKosul: Boolean; aTrue, aFalse: String): String; overload;
      function _f(const aFormat: string; const Args: array of const): string;
      function _NS: String;
    public
      function AsString: String; // Bu noktada zincir kırılır...
      function Version(Value: Double): TFluentXML;
      function Encoding(Value: TEncoding): TFluentXML;
      function NameSpace(Value: String): TFluentXML;
      function Add(aNode: string): TFluentXML; overload;
      function Add(aNode: string; aCloseWithoutSlash: Boolean): TFluentXML; overload;
      function Add(aNode: string; aValue: Variant): TFluentXML; overload;
      function Add(aNode: string; aSubNode: TFluentXML): TFluentXML; overload;
      function Add(aNode: string; aAttributes: TVarArray): TFluentXML; overload;
      function Add(aNode: string; aAttributes: TVarArray; aValue: Variant): TFluentXML; overload;
      function Add(aNode: string; aAttributes: TVarArray; aSubNode: TFluentXML): TFluentXML; overload;
      function SaveToFile(aFileName: TFileName): TFluentXML;
      function FormatXml: TFluentXML;
      class function New(aVersion: Double; aEncoding: TEncoding): TFluentXML;
  end;
  function New: TFluentXML; overload;
  function FluentXML: TFluentXML;

implementation

function New: TFluentXML;
begin
  Result := TFluentXML.Create;
end;

function FluentXML: TFluentXML;
begin
  Result := TFluentXML.Create;
end;

{ TXML2 }

function TFluentXML.AsString: String;
var
  Tmp: String;
  FS: TFormatSettings;
begin
  FS := FormatSettings;
  FormatSettings.DecimalSeparator := '.';
  Tmp := _Encoding.AsEncoderName;
  if (Pos( '<?xml version',_Source, 1) <= 0) then begin
      _Source := _if( ((_Version <> 0) or (Tmp.IsEmpty = False))
                    , _f ( '<?xml%s%s?>',
                         [ _if(_Version <> 0, _f(' version="%s"', [ formatfloat('0.0',_Version)]), '')
                         , _if(Tmp.IsEmpty = False, _f(' encoding="%s"', [Tmp]), '')
                         ])
                    , '')
               + sLineBreak + _Source
               ;
  end;
  FormatSettings := FS;
  //Result := StringReplace(_Source, '><', '>'#13#10'<', [rfReplaceAll, rfIgnoreCase]); // CDATA içinde geçerse sıkıntı olabilir...
  Result := _Source.Trim;
end;

function TFluentXML.Version(Value: Double): TFluentXML;
begin
  _Version := Value;
  Result := Self;
end;

class function TFluentXML.New(aVersion: Double; aEncoding: TEncoding): TFluentXML;
begin
  Result := TFluentXML.Create;
  Result.Version(aVersion);
  Result.Encoding(aEncoding);
end;

function TFluentXML.Encoding(Value: TEncoding): TFluentXML;
begin
  _Encoding := Value;
  Result := Self;
end;

function TFluentXML.FormatXml: TFluentXML;
var
  I: Integer;
  B: Integer;
  T: string;
  O: Char;  //  önceki
  X: Char;  //  şimdiki
  N: Char;  //  sonraki
  Ek: string;
  TabCount  : Integer;
  TagInside : Boolean;
  Tirnak    : Boolean;
  cData     : Boolean;
begin
  B := Length(_Source);
  X := #0;
  TabCount    := 0;
  TagInside   := (_Source[1] = '<');
  Tirnak      := FALSE;
  cData       := FALSE;
  for I := 1 to B do begin
      Ek := '';
      O := X;
      X := _Source[I];
      if (I < B) then N := _Source[I + 1] else N := #0;
      if (I < B - 2) then begin
          if (X = '<') and (N = '!') then cData := True;
          if (O = ']') and (X = '>') then cData := FALSE;
      end;
      if (X = '"') then Tirnak := Not Tirnak;
      if ((Tirnak = FALSE) and (cData = False)) then begin
          case TagInside of
               FALSE: Begin
                        if (X = '<') then begin
                            TagInside := True;
                            Inc(TabCount);
                            if (N = '/')
                            or (N = '!') then begin
                                Dec(TabCount, 1); { </ } { veya } { <! }
                            end;
                        end;
                      End;
               TRUE : begin
                        if (O = '<') and (X = '/')  then Dec(TabCount, 1);
                        if (X = '>') then begin
                            TagInside := False;
                            if (O = '/') then begin
                                Dec(TabCount); { /> }
                            end;
                            if (N = '<') then begin          { >< }
                                Ek := #13#10 + DupeString(#9, TabCount);// + '{' + TabCount.ToString + '}';
                                if (I < B - 2) then begin
                                    if (_Source[I+2] = '!') then Ek := ''; { <! }
                                end;
                            end;
                        end;
                      end;
          end;
      end;
      T := T + X + Ek;
  end;
  //T := StringReplace(T, #9'</', '</', [rfReplaceAll]);
  B := T.Trim.Length;
  _Source := T.Trim;
  T := '';
  for I := 1 to B do begin
      O := _Source[I];
      if (I < B - 2) then begin
          X := _Source[I+1];
          N := _Source[I+2];
      end else begin
          X := #0;
          N := #0;
      end;
      if NOT ( (O = #9) and (X = '<') and (N = '/') ) then T := T + O;
  end;
  _Source := T;
  Result := Self;
end;

function TFluentXML.NameSpace(Value: String): TFluentXML;
begin
  _NameSpace := Value.Trim;
  Result := Self;
end;

function TFluentXML.Add(aNode: string): TFluentXML;
begin
  _Source := _Source + _f('<%s/>', [aNode.Trim]);
  Result := Self;
end;

function TFluentXML.Add(aNode: string; aCloseWithoutSlash: Boolean): TFluentXML;
begin
  if aCloseWithoutSlash then
    _Source := _Source + _f('<%s>', [aNode.Trim])
  else
    _Source := _Source + _f('<%s/>', [aNode.Trim]);
  Result := Self;
end;

function TFluentXML.Add(aNode: string; aValue: Variant): TFluentXML;
begin
  _Source := _Source + _f('<%0:s%1:s>%2:s</%0:s%1:s>', [_NS, aNode.Trim, VarToStr(aValue).Trim]);
  Result := Self;
end;

function TFluentXML.Add(aNode: string; aSubNode: TFluentXML): TFluentXML;
var
  Tmp: Variant;
begin
  if (Assigned(aSubNode) = TRUE) then begin
      Tmp := aSubNode.AsString;
      FreeAndNil(aSubNode);
      Result := Self.Add(aNode, Tmp);
  end else begin
      Result := Self;
  end;
end;

function TFluentXML.Add(aNode: string; aAttributes: TVarArray; aValue: Variant): TFluentXML;
var
  Tmp: String;
begin
  Tmp := aAttributes.Split(' ').Trim;
  _Source := _Source
           + _f('<%0:s%1:s%2:s>%3:s</%0:s%1:s>', [_NS, aNode.Trim, _if(Tmp.IsEmpty = True, '', ' ' + Tmp), VarToStr(aValue).Trim]) ;
  Result := Self;
end;

function TFluentXML.Add(aNode: string; aAttributes: TVarArray; aSubNode: TFluentXML): TFluentXML;
var
  Tmp: Variant;
begin
  if (Assigned(aSubNode) = TRUE) then begin
      Tmp := aSubNode.AsString;
      FreeAndNil(aSubNode);
      Result := Self.Add(aNode, aAttributes, Tmp);
  end else begin
      Result := Self;
  end;
end;

function TFluentXML.Add(aNode: string; aAttributes: TVarArray): TFluentXML;
var
  Tmp: String;
begin
  Tmp := aAttributes.Split(' ');
  _Source := _Source + _f('<%0:s%1:s%2:s/>', [_NS, aNode.Trim, _if(Tmp.IsEmpty = True, '', ' ' + Tmp)]) ;
  Result := Self;
end;

function TFluentXML._f(const aFormat: string; const Args: array of const): string;
begin
  Result := Format(aFormat, Args);
end;

function TFluentXML._if(aKosul: Boolean; aTrue, aFalse: String): String;
begin
  if (aKosul = TRUE) then Result := aTrue else Result := aFalse;
end;

function TFluentXML._NS: String;
begin
  Result := _if( (_NameSpace.Trim.IsEmpty = True), '', _NameSpace.Trim+':');
end;

function TFluentXML.SaveToFile(aFileName: TFileName): TFluentXML;
var
  Dosya : TStreamWriter;
begin
  try
    if (directoryExists(ExtractFileDir(aFileName), True) = TRUE) then begin
        try
          Dosya := TStreamWriter.Create(aFileName, False, TEncoding.UTF8);
          Dosya.Write(Self.AsString);
          Dosya.Close;
        finally
          FreeAndNil(Dosya);
        end;
    end else begin
        ShowMessage('Directory not found');
    end;
  finally
    Result := Self;
  end;
end;

{ TVarArrayHelper }

function TFluentXML.TVarArrayHelper.Split(aDelimiter: String): String;
var
  I: Integer;
begin
  for I := Low(Self) to High(Self)
  do if  (I < High(Self) )
     then Result := Result + VarToStrDef(Self[I], '').Trim + aDelimiter
     else Result := Result + VarToStrDef(Self[I], '').Trim;
end;

{ TEncodingHelper }

function TFluentXML.TEncodingHelper.AsEncoderName: String;
begin
  {-- Sources ------------------------------------------------------------------------}
  { https://docs.microsoft.com/en-us/dotnet/standard/base-types/character-encoding    }
  { http://www.iana.org/assignments/character-sets/character-sets.xhtml               }
  {-----------------------------------------------------------------------------------}
  if (Self = TEncoding.ANSI)             then Result := 'ANSI'         else
  if (Self = TEncoding.ASCII)            then Result := 'ASCII'        else
  if (Self = TEncoding.UTF7)             then Result := 'UTF-7'        else
  if (Self = TEncoding.UTF8)             then Result := 'UTF-8'        else
  if (Self = TEncoding.Unicode)          then Result := 'UTF-16'       else
  if (Self = TEncoding.BigEndianUnicode) then Result := 'UTF-16BE'     else
  if (Self = TEncoding.Default)          then Result := 'Windows-1254' else
  Result := '';
end;

end.
