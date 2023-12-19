unit Ths.Utils.Images;

interface

uses SysUtils, Classes, StdCtrls, ExtCtrls, Graphics, System.NetEncoding, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, Ths.Database.Table;

type
  TImageProcess = class
    class procedure LoadImageFromDB(AField: TFieldDB; AImage: TImage);
    class procedure setValueFromImage(AField: TFieldDB; AImage: TImage);
  end;

implementation

{ TImageProcess }

class procedure TImageProcess.LoadImageFromDB(AField: TFieldDB; AImage: TImage);
var
  LStream: TMemoryStream;
  LBytes: TBytes;
begin
  if AField.AsString = '' then
    Exit;

  LStream := TMemoryStream.Create;
  try
    LBytes := AField.Value;
    LStream.Position := 0;
    LStream.Write(LBytes, Length(LBytes));
    LStream.Position := 0;
    if LStream.Size > 0 then
    begin
      AImage.Picture.LoadFromStream(LStream);
    end;
  finally
    LStream.Free;
  end;
end;

class procedure TImageProcess.setValueFromImage(AField: TFieldDB; AImage: TImage);
var
  LStream: TStringStream;
begin
  LStream := TStringStream.Create;
  try
    AField.Value := '';
    AImage.Picture.SaveToStream(LStream);

    if LStream.Size > 0 then
      AField.Value := LStream.Bytes;
  finally
    LStream.Free;
  end;
end;

end.
