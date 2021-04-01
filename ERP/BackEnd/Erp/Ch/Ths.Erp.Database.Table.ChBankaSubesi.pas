unit Ths.Erp.Database.Table.ChBankaSubesi;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.ChBanka,
  Ths.Erp.Database.Table.SysSehir;

type
  TChBankaSubesi = class(TTable)
  private
    FBankaID: TFieldDB;
    FBanka: TFieldDB;
    FSubeKodu: TFieldDB;
    FSubeAdi: TFieldDB;
    FSubeIlID: TFieldDB;
    FSubeIl: TFieldDB;
  protected
    FChBanka: TChBanka;
    FSehir: TSysSehir;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property BankaID: TFieldDB read FBankaID write FBankaID;
    Property Banka: TFieldDB read FBanka write FBanka;
    Property SubeKodu: TFieldDB read FSubeKodu write FSubeKodu;
    Property SubeAdi: TFieldDB read FSubeAdi write FSubeAdi;
    Property SubeIlID: TFieldDB read FSubeIlID write FSubeIlID;
    Property SubeIl: TFieldDB read FSubeIl write FSubeIl;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TChBankaSubesi.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_banka_subesi';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FChBanka := TChBanka.Create(ADatabase);
  FSehir := TSysSehir.Create(ADatabase);

  FBankaID := TFieldDB.Create('banka_id', ftInteger, 0, Self, 'Banka ID');
  FBanka := TFieldDB.Create(FChBanka.BankaAdi.FieldName, FChBanka.BankaAdi.DataType, '', Self, 'Banka');
  FSubeKodu := TFieldDB.Create('sube_kodu', ftInteger, 0, Self, 'Þube Kodu');
  FSubeAdi := TFieldDB.Create('sube_adi', ftString, '', Self, 'Þube Adý');
  FSubeIlID := TFieldDB.Create('sube_il_id', ftInteger, 0, Self, 'Þube Ýl ID');
  FSubeIl := TFieldDB.Create(FSehir.SehirAdi.FieldName, FSehir.SehirAdi.DataType, '', Self, 'Þube Þehir');
end;

destructor TChBankaSubesi.Destroy;
begin
  FChBanka.Free;
  FSehir.Free;
  inherited;
end;

procedure TChBankaSubesi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FBankaID.FieldName,
        addLangField(FBanka.FieldName),
        TableName + '.' + FSubeKodu.FieldName,
        FSubeAdi.FieldName,
        TableName + '.' + FSubeIlID.FieldName,
        addLangField(FSubeIl.FieldName)
      ], [
        addLeftJoin(FBanka.FieldName, FBankaID.FieldName, FChBanka.TableName),
        addLeftJoin(FSubeIl.FieldName, FSubeIlID.FieldName, FSehir.TableName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FBankaID, 'Banka ID', QueryOfDS);
      setFieldTitle(FBanka, 'Banka', QueryOfDS);
      setFieldTitle(FSubeKodu, 'Þube Kodu', QueryOfDS);
      setFieldTitle(FSubeAdi, 'Þube Adý', QueryOfDS);
      setFieldTitle(FSubeIlID, 'Þube Ýl ID', QueryOfDS);
      setFieldTitle(FSubeIl, 'Þube Ýl', QueryOfDS);
    end;
  end;
end;

procedure TChBankaSubesi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
        TableName + '.' + FBankaID.FieldName,
        addLangField(FBanka.FieldName),
        TableName + '.' + FSubeKodu.FieldName,
        FSubeAdi.FieldName,
        TableName + '.' + FSubeIlID.FieldName,
        addLangField(FSubeIl.FieldName)
      ], [
        addLeftJoin(FBanka.FieldName, FBankaID.FieldName, FChBanka.TableName),
        addLeftJoin(FSubeIl.FieldName, FSubeIlID.FieldName, FSehir.TableName),
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
    end;
  end;
end;

procedure TChBankaSubesi.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FBankaID.FieldName,
        FSubeKodu.FieldName,
        FSubeAdi.FieldName,
        FSubeIlID.FieldName
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

procedure TChBankaSubesi.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FBankaID.FieldName,
        FSubeKodu.FieldName,
        FSubeAdi.FieldName,
        FSubeIlID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TChBankaSubesi.Clone: TTable;
begin
  Result := TChBankaSubesi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
