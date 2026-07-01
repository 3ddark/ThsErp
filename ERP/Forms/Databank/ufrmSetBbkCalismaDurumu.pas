unit ufrmSetBbkCalismaDurumu;

interface

{$I Ths.inc}

uses
  Windows,
  System.Classes,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetBbkCalismaDurumu = class(TfrmBaseInputDB)
    lblcalisma_durumu: TLabel;
    edtcalisma_durumu: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals,
  Ths.Database.Table.SetBbkCalismaDurumu;

procedure TfrmSetBbkCalismaDurumu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkCalismaDurumu(Table).CalismaDurumu.Value := edtcalisma_durumu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkCalismaDurumu.RefreshData;
begin
  edtcalisma_durumu.Text := TSetBbkCalismaDurumu(Table).CalismaDurumu.AsString;
end;

end.
