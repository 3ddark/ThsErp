unit ufrmSysGridFiltrelerSiralamalar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter,
  ufrmBase, ufrmBaseDBGrid;

type
  TfrmSysGridFiltrelerSiralamalar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysGridFiltrelerSiralama,
  Ths.Database.Table.SysGridFiltrelerSiralamalar;

{$R *.dfm}

function TfrmSysGridFiltrelerSiralamalar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysGridFilterSort.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysGridFilterSort.Create(Self, Self, TSysGridFiltreSiralama.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridFilterSort.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysGridFiltrelerSiralamalar.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
