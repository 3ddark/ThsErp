unit Ths.Database.Table.ChHesapPlanlari;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table;

type
  TChHesapPlani = class(TTable)
  private
    FPlanKodu: TFieldDB;
    FPlanAdi: TFieldDB;
    FSeviye: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property PlanKodu: TFieldDB read FPlanKodu write FPlanKodu;
    Property PlanAdi: TFieldDB read FPlanAdi write FPlanAdi;
    Property Seviye: TFieldDB read FSeviye write FSeviye;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.ChHesapKarti,
  Ths.Database.Table.ChHesapHareketi;

constructor TChHesapPlani.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesap_planlari';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FPlanKodu := TFieldDB.Create('plan_kodu', ftString, '', Self);
  FPlanAdi := TFieldDB.Create('plan_adi', ftString, '', Self);
  FSeviye := TFieldDB.Create('seviye', ftInteger, 0, Self);
end;

function TChHesapPlani.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FPlanKodu.FieldName,
      TableName + '.' + FPlanAdi.FieldName,
      TableName + '.' + FSeviye.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapPlani.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FPlanKodu.FieldName,
      TableName + '.' + FPlanAdi.FieldName,
      TableName + '.' + FSeviye.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Self.Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TChHesapPlani.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FPlanKodu.FieldName,
      FPlanAdi.FieldName,
      FSeviye.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapPlani.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FPlanKodu.FieldName,
      FPlanAdi.FieldName,
      FSeviye.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapPlani.BusinessDelete(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    with Database.NewQuery do
    try
      Close;
      SQL.Clear;
      SQL.Text := 'SELECT COUNT(*) FROM ' + LHesap.TableName + ' WHERE ' +
        LHesap.HesapKodu.QryName + ' LIKE ' + QuotedStr(FPlanKodu.AsString + '%') + ' AND ' +
        LHesap.HesapTipiID.QryName + '<>' + IntToStr(Ord(THesapTipi.htAna));
      Open;

      if (not Fields.Fields[0].IsNull) and (Fields.Fields[0].AsInteger > 0) then
        raise Exception.Create(Trim('Hesap Planına bağlı Cari Hesap olan kayıtlar silinemez!' + AddLBs(2) +
                              'Önce Cari Hesap Kartını silin! + 999999'));
    finally
      Free;
    end;
    Delete(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TChHesapPlani.BusinessInsert(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LHesap.HesapKodu.Value := Self.FPlanKodu.Value;
    LHesap.HesapIsmi.Value := UpperCaseTr(Self.FPlanAdi.AsString);
    LHesap.KokKod.Value := Self.FPlanKodu.Value;

    //120-1-2     3 seviye
    //600-1       2 seviye
    //760         1 seviye
    //Seviye 1 ise oluşan Hesap Son Hesap olur
    //Seviye 2 ise oluşan Hesap Ana Hesap olur
    //Seviye 3 ise oluşan Hesap Ana Hesap olur
    if Self.Seviye.Value > 1
    then  LHesap.HesapTipiID.Value := THesapTipi.htAna
    else  LHesap.HesapTipiID.Value := THesapTipi.htSon;

    LHesap.Insert(False);

    Self.Insert(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TChHesapPlani.BusinessUpdate(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LHesap.HesapKodu.Value := Self.FPlanKodu.Value;
    LHesap.HesapIsmi.Value := Self.FPlanAdi.Value;
    if Self.Seviye.Value > Ord(THesapTipi.htAna)
    then  LHesap.HesapTipiID.Value := THesapTipi.htAna
    else  LHesap.HesapTipiID.Value := THesapTipi.htSon;
    LHesap.KokKod.Value := Self.FPlanKodu.Value;

    LHesap.Update(False);

    Self.Update(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

function TChHesapPlani.Clone: TTable;
begin
  Result := TChHesapPlani.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



