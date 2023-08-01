unit ufrmSetPrsAyrilmaNedenleri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Data.DB,
  ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSetPrsAyrilmaNedenleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmSetPrsAyrilmaNedeni,
  Ths.Database.Table.SetPrsAyrilmaNedenleri;

{$R *.dfm}

function TfrmSetPrsAyrilmaNedenleri.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSetPrsAyrilmaNedeni.Create(Application, Self, Table.Clone(), AFormMode)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSetPrsAyrilmaNedeni.Create(Application, Self, TSetEmpLeavingReason.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSetPrsAyrilmaNedeni.Create(Application, Self, Table.Clone(), AFormMode);
end;

end.
