unit ufrmSysKaynaklar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.DBGrids,
  Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, System.Actions, Vcl.ActnList,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf;

type
  TfrmSysKaynaklar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table, ufrmSysKaynakGrubu, Ths.Database.Table.SysKaynaklar;

{$R *.dfm}

function TfrmSysKaynaklar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysKaynakGrubu.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysKaynakGrubu.Create(Self, Self, TSysKaynak.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysKaynakGrubu.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysKaynaklar.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysKaynaklar.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;

  setDisplayFormatInteger(TSysKaynak(Table).KaynakKodu.FieldName, '', grd.DataSource.DataSet);
end;

end.

