unit Ths.DialogHelper;

interface

uses
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Math;

type
  TThsDialogHelper = class
    class function CustomMsgDlg(const AMsg: string; ADlgType: TMsgDlgType;
      AButtons: TMsgDlgButtons; ACaptions: array of string; ADefaultButton: TMsgDlgBtn;
      ACustomTitle: string = ''; AFontName: string = ''): Integer;
  end;

implementation

class function TThsDialogHelper.CustomMsgDlg(const AMsg: string; ADlgType: TMsgDlgType; AButtons: TMsgDlgButtons; ACaptions: array of string; ADefaultButton: TMsgDlgBtn; ACustomTitle: string; AFontName: string): Integer;
var
  vMsgDlg: TForm;
  n1, nCaption, widthTotal, LTotalBtnWidth: Integer;
  vDlgButton: TButton;
  fontName: string;
  buttonNames: array of TButton;
begin
  vMsgDlg := CreateMessageDialog(AMsg, ADlgType, AButtons, ADefaultButton);
  if AFontName = '' then
    fontName := 'Tahoma'
  else
    fontName := AFontName;

  SetLength(buttonNames, 0);
  nCaption := 0;
  widthTotal := 0;
  LTotalBtnWidth := 0;

  vMsgDlg.Font.Name := fontName;
  vMsgDlg.Canvas.Font.Name := fontName;

  if ACustomTitle <> '' then
    vMsgDlg.Caption := ACustomTitle;

  for n1 := 0 to vMsgDlg.ComponentCount - 1 do
  begin
    if (vMsgDlg.Components[n1] is TButton) then
    begin
      vDlgButton := TButton(vMsgDlg.Components[n1]);
      if nCaption > High(ACaptions) then
        Break;

      //font deðiþtir
      vDlgButton.Font.Name := fontName;
      //custom caption ata
      vDlgButton.Caption := ACaptions[nCaption];
      //yazýya göre buton geniþliðini ayarla
      vDlgButton.Width := Max(vMsgDlg.Canvas.TextWidth(vDlgButton.Caption) + (8 * 2), 75);

      LTotalBtnWidth := LTotalBtnWidth + vDlgButton.Width;

      //butonlarýn arasýnda 8 boþluk býrak
      //soldan da 8 boþluk için +8 yapýyoruz
      if nCaption = 0 then
        widthTotal := 8;
      widthTotal := widthTotal + vDlgButton.Width + 12;
      Inc(nCaption);

      //butonlarýn left pozisyonlarýný ayarlamak için array içinde tutuyoruz
      SetLength(buttonNames, nCaption);
      buttonNames[nCaption - 1] := vDlgButton;
    end;
  end;

  if widthTotal > vMsgDlg.Width then
    vMsgDlg.Width := widthTotal;

  for n1 := 0 to Length(buttonNames) - 1 do
  begin
    if n1 = 0 then
      buttonNames[n1].Left := (vMsgDlg.Width - (LTotalBtnWidth + ((nCaption - 1) * 16))) div 2//widthTotal - buttonNames[n1].Width - posLeft - 8
    else
      buttonNames[n1].Left := buttonNames[n1 - 1].Left + buttonNames[n1 - 1].Width + 16;
  end;

  Result := vMsgDlg.ShowModal;
end;

end.

