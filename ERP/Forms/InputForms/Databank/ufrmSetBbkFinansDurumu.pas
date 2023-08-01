unit ufrmSetBbkFinansDurumu;

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
  TfrmSetBbkFinansDurumu = class(TfrmBaseInputDB)
    lblfinans_durumu: TLabel;
    edtfinans_durumu: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals,
  Ths.Database.Table.SetBbkFinansDurumu;

procedure TfrmSetBbkFinansDurumu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkFinansDurumu(Table).FinansDurumu.Value := edtfinans_durumu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkFinansDurumu.RefreshData;
begin
  edtfinans_durumu.Text := FormatedVariantVal(TSetBbkFinansDurumu(Table).FinansDurumu);
end;

end.
