unit ufrmEmpEmployees;

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
  TfrmEmpEmployees = class(TfrmBaseDBGrid)
    procedure mniPrintClick(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  ufrmEmpEmployee,
  Ths.Database.Table.EmpEmployee,
  Ths.Constants;

{$R *.dfm}

function TfrmEmpEmployees.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmEmpEmployee.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmEmpEmployee.Create(Self, Self, TEmpEmployee.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpEmployee.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmEmpEmployees.FormShow(Sender: TObject);
begin
  inherited;
  mniprint.Visible := True;
end;

procedure TfrmEmpEmployees.mniPrintClick(Sender: TObject);
begin
  inherited;
  //
end;

end.

