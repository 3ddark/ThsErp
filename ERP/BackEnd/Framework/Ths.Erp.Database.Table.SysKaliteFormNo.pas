unit Ths.Erp.Database.Table.SysKaliteFormNo;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKaliteFormTipi;

type
  TSysQualityFormNumber = class(TTable)
  private
    FTabloAdi: TFieldDB;
    FFormNo: TFieldDB;
    FFormTipiID: TFieldDB;
    FFormTipi: TFieldDB;

    FQtyFormType: TSysKaliteFormTipi;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property FormNo: TFieldDB read FFormNo write FFormNo;
    Property FormTipiID: TFieldDB read FFormTipiID write FFormTipiID;
    Property FormTipi: TFieldDB read FFormTipi write FFormTipi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysQualityFormNumber.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_kalite_form_no';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FQtyFormType := TSysKaliteFormTipi.Create(Database);

  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Tablo Adý');
  FFormNo := TFieldDB.Create('form_no', ftString, '', Self, 'Form No');
  FFormTipiID := TFieldDB.Create('form_tipi_id', ftInteger, 0, Self, 'Form Tipi ID');
  FFormTipi := TFieldDB.Create(FQtyFormType.FormTipi.FieldName, FQtyFormType.FormTipi.DataType, '', Self, 'Form Tipi');
end;

destructor TSysQualityFormNumber.Destroy;
begin
  FreeAndNil(FQtyFormType);
  inherited;
end;

procedure TSysQualityFormNumber.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FFormNo.FieldName,
        TableName + '.' + FFormTipiID.FieldName,
        addLangField(FFormTipi.FieldName)
      ], [
        addLeftJoin(FFormTipi.FieldName, FFormTipiID.FieldName, FQtyFormType.TableName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTabloAdi, 'Tablo Adý', QueryOfDS);
      setFieldTitle(FFormNo, 'Form Numarasý', QueryOfDS);
      setFieldTitle(FFormTipiID, 'Giriþ Tipi ID', QueryOfDS);
      setFieldTitle(FFormTipi, 'Giriþ Tipi', QueryOfDS);
    end;
  end;
end;

procedure TSysQualityFormNumber.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      SQL.Clear;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FFormNo.FieldName,
        TableName + '.' + FFormTipiID.FieldName,
        addLangField(FFormTipi.FieldName)
      ], [
        addLeftJoin(FFormTipi.FieldName, FFormTipiID.FieldName, FQtyFormType.TableName),
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

procedure TSysQualityFormNumber.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTabloAdi.FieldName,
        FFormNo.FieldName,
        FFormTipiID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysQualityFormNumber.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTabloAdi.FieldName,
        FFormNo.FieldName,
        FFormTipiID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysQualityFormNumber.Clone():TTable;
begin
  Result := TSysQualityFormNumber.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
