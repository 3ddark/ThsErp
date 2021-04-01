unit Ths.Erp.Database.Table.ChBanka;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TChBanka = class(TTable)
  private
    FBankaAdi: TFieldDB;
    FSwiftKodu: TFieldDB;
    FIsActive: TFieldDB;
  protected
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property BankaAdi: TFieldDB read FBankaAdi write FBankaAdi;
    Property SwiftKodu: TFieldDB read FSwiftKodu write FSwiftKodu;
    Property IsActive: TFieldDB read FIsActive write FIsActive;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TChBanka.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_banka';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FBankaAdi := TFieldDB.Create('banka_adi', ftString, '', Self, 'Banka Adý');
  FSwiftKodu := TFieldDB.Create('swift_kodu', ftString, '', Self, 'Swift Kodu');
  FIsActive := TFieldDB.Create('is_active', ftBoolean, True, Self, 'Aktif');
end;

procedure TChBanka.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FBankaAdi.FieldName,
        TableName + '.' + FSwiftKodu.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FBankaAdi, 'Adý', QueryOfDS);
      setFieldTitle(FSwiftKodu, 'Swift Kodu', QueryOfDS);
      setFieldTitle(FIsActive, 'Aktif?', QueryOfDS);
    end;
  end;
end;

procedure TChBanka.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FBankaAdi.FieldName,
        TableName + '.' + FSwiftKodu.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TChBanka.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FBankaAdi.FieldName,
        FSwiftKodu.FieldName,
        FIsActive.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TChBanka.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FBankaAdi.FieldName,
        FSwiftKodu.FieldName,
        FIsActive.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TChBanka.Clone: TTable;
begin
  Result := TChBanka.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
