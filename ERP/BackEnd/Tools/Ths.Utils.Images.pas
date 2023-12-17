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
  AImage.Picture.Assign(nil);
  if AField.AsString = '' then
    Exit;

  LStream := TMemoryStream.Create;
  try
    LBytes := AField.Value;
    LStream.Write(LBytes, Length(LBytes));
    LStream.Position := 0;
    AImage.Picture.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

class procedure TImageProcess.setValueFromImage(AField: TFieldDB; AImage: TImage);
var
  LInput: TMemoryStream;
  LOutput: TStringStream;
begin
  LInput := TMemoryStream.Create;
  LOutput := TStringStream.Create;
  try
    AField.Value := '';
    if Assigned(AImage.Picture.Graphic) then
      AImage.Picture.Graphic.SaveToStream(LInput)
    else if Assigned(AImage.Picture.Bitmap) then
      AImage.Picture.Bitmap.SaveToStream(LInput);

    LInput.Position := 0;
    if LInput.Size > 0 then
    begin
      TNetEncoding.Base64.Encode(LInput, LOutput);
      AField.Value := LOutput.Bytes;
    end;
  finally
    LInput.Free;
    LOutput.Free;
  end;
end;

end.
