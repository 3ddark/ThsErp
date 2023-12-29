unit Ths.Utils.Images;

interface

uses SysUtils, Classes, StdCtrls, ExtCtrls, Graphics, System.NetEncoding, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, Ths.Database.Table;

type
  TImageProcess = class
    class procedure LoadImageFromFile(AFileName: string; AImage: TImage; AMaxWidth: Integer = 0; AMaxHeight: Integer = 0);
    class procedure LoadImageFromDB(AField: TFieldDB; AImage: TImage);
    class procedure setValueFromImage(AField: TFieldDB; AImage: TImage);
    class procedure DrawEmptyImage(AImage: TImage; AMaxWidth, AMaxHeight: Integer);
  end;

implementation

uses Ths.Constants;

class procedure TImageProcess.LoadImageFromFile(AFileName: string; AImage: TImage; AMaxWidth, AMaxHeight: Integer);
var
  LRightOrigin: Integer;
  LImgJ: TJPEGImage;
  LImgP: TPngImage;
  LStream: TMemoryStream;
begin
  LRightOrigin := AImage.Left + AImage.Width;

  LStream := TMemoryStream.Create;
  try
    if ExtractFileExt(AFileName).Replace('.', '') = FILE_EXT_BMP then
    begin
      AImage.Picture.Bitmap.LoadFromFile(AFileName);
    end
    else if ExtractFileExt(AFileName).Replace('.', '') = FILE_EXT_JPG then
    begin
      LImgJ := TJPEGImage.Create;
      try
        LStream.LoadFromFile(AFileName);
        LStream.Position := 0;
        LImgJ.LoadFromStream(LStream);
        AImage.Picture.Bitmap.Assign(LImgJ);
      finally
        LImgJ.Free;
      end;
    end
    else if ExtractFileExt(AFileName).Replace('.', '') = FILE_EXT_PNG then
    begin
      LImgP := TPngImage.Create;
      try
        LStream.LoadFromFile(AFileName);
        LStream.Position := 0;
        LImgP.LoadFromStream(LStream);
        AImage.Picture.Bitmap.Assign(LImgP);
      finally
        LImgP.Free;
      end;
    end;
  finally
    LStream.Free;
  end;

  if (AMaxWidth > 0) and (AImage.Picture.Bitmap.Width > AMaxWidth) then
  begin
    AImage.Picture.Assign(nil);
    DrawEmptyImage(AImage, AMaxWidth, AMaxHeight);
    raise Exception.Create('Logo geniþliði en fazla ' + AMaxWidth.ToString + 'px olabilir.');
  end
  else if (AMaxHeight > 0) and (AImage.Picture.Bitmap.Height > AMaxHeight) then
  begin
    AImage.Picture.Assign(nil);
    DrawEmptyImage(AImage, AMaxWidth, AMaxHeight);
    raise Exception.Create('Logo yüksekliði en fazla ' + AMaxHeight.ToString + 'px olabilir.');
  end;

  AImage.Width := AImage.Picture.Bitmap.Width;
  AImage.Height := AImage.Picture.Bitmap.Height;
  AImage.Left := LRightOrigin - AImage.Width;
end;

class procedure TImageProcess.DrawEmptyImage(AImage: TImage; AMaxWidth, AMaxHeight: Integer);
var
  LRightOrigin, x1, x2, y1, y2: Integer;
begin
  with AImage do
  begin
    LRightOrigin := Left + Width;
    Width := AMaxWidth;
    Height := AMaxHeight;
    Left := LRightOrigin - Width;

    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;

    Canvas.Pen.Color := clOlive;
    Canvas.Brush.Color := clOlive;
    x1 := 0;
    x2 := Width;
    y1 := 0;
    y2 := Height;
    Canvas.Rectangle(x1, y1, x2, y2);
  end;
end;

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
