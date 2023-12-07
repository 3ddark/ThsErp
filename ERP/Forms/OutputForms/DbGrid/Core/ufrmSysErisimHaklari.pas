unit ufrmSysErisimHaklari;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Actions, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Vcl.ActnList, Data.DB,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf;

type
  TfrmSysErisimHaklari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table, ufrmSysErisimHakki, Ths.Database.Table.SysErisimHaklari;

{$R *.dfm}

function TfrmSysErisimHaklari.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysErisimHakki.Create(Self, Self, Table.Clone(), AFormMode)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysErisimHakki.Create(Self, Self, TSysErisimHakki.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysErisimHakki.Create(Self, Self, Table.Clone(), AFormMode);
end;

procedure TfrmSysErisimHaklari.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysErisimHaklari.FormShow(Sender: TObject);
begin
  inherited;

  setDisplayFormatInteger(TSysErisimHakki(Table).KaynakKodu.FieldName, '0', grd.DataSource.DataSet);

  mnicopy_record.Visible := True;
end;

end.

