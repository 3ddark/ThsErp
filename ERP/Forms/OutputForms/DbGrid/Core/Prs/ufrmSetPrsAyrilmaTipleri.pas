unit ufrmSetPrsAyrilmaTipleri;

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
  TfrmSetPrsAyrilmaTipleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmSetPrsAyrilmaTipi,
  Ths.Database.Table.SetPrsAyrilmaTipleri;

{$R *.dfm}

function TfrmSetPrsAyrilmaTipleri.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSetPrsAyrilmaTipi.Create(Application, Self, Table.Clone(), AFormMode)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSetPrsAyrilmaTipi.Create(Application, Self, TSetPrsAyrilmaTipi.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSetPrsAyrilmaTipi.Create(Application, Self, Table.Clone(), AFormMode);
end;

end.
