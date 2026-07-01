unit ufrmSetUrtIscilikTipi;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetUrtIscilikTipi = class(TfrmBaseInputDB)
    edtgider_tipi: TEdit;
    lblgider_tipi: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table.SetUrtIscilikTipleri;

{$R *.dfm}

procedure TfrmSetUrtIscilikTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBomLabourType(Table).LabourType.Value := edtgider_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetUrtIscilikTipi.RefreshData;
begin
  edtgider_tipi.Text := TSetBomLabourType(Table).LabourType.AsString;
end;

end.
