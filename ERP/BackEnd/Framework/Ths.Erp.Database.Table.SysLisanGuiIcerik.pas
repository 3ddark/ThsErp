unit Ths.Erp.Database.Table.SysLisanGuiIcerik;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysLisan;

type
  TSysLisanGuiIcerik = class(TTable)
  private
    FLisan: TFieldDB;
    FKod: TFieldDB;
    FIcerikTipi: TFieldDB;
    FTabloAdi: TFieldDB;
    FDeger: TFieldDB;
    FIsFabrikaAyari: TFieldDB;
    FFormAdi: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Lisan: TFieldDB read FLisan write FLisan;
    property Kod: TFieldDB read FKod write FKod;
    property IcerikTipi: TFieldDB read FIcerikTipi write FIcerikTipi;
    property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    property Deger: TFieldDB read FDeger write FDeger;
    property IsFabrikaAyari: TFieldDB read FIsFabrikaAyari write FIsFabrikaAyari;
    property FormAdi: TFieldDB read FFormAdi write FFormAdi;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysLisanGuiIcerik.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_lisan_gui_icerik';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FLisan := TFieldDB.Create('lisan', ftString, '', Self, 'Lisan');
  FKod := TFieldDB.Create('kod', ftString, 'Kod', Self, 'Kod');
  FIcerikTipi := TFieldDB.Create('icerik_tipi', ftString, '', Self, 'Ýçerik Tipi');
  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Tablo Adý');
  FDeger := TFieldDB.Create('deger', ftString, '', Self, 'Deðer');
  FIsFabrikaAyari := TFieldDB.Create('is_fabrika_ayari', ftBoolean, False, Self, 'Fabrika Ayarý?');
  FFormAdi := TFieldDB.Create('form_adi', ftString, '', Self, 'Form Adý');
end;

procedure TSysLisanGuiIcerik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FLisan.FieldName,
        TableName + '.' + FKod.FieldName,
        TableName + '.' + FIcerikTipi.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FDeger.FieldName + '::varchar ',
        TableName + '.' + FIsFabrikaAyari.FieldName,
        TableName + '.' + FFormAdi.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FLisan, 'Lisan', QueryOfDS);
      setFieldTitle(FKod, 'Kod', QueryOfDS);
      setFieldTitle(FIcerikTipi, 'Ýçerik Tipi', QueryOfDS);
      setFieldTitle(FTabloAdi, 'Tablo Adý', QueryOfDS);
      setFieldTitle(FDeger, 'Deðer', QueryOfDS);
      setFieldTitle(FIsFabrikaAyari, 'Fabrika Ayarý?', QueryOfDS);
      setFieldTitle(FFormAdi, 'Form Adý', QueryOfDS);
    end;
  end;
end;

procedure TSysLisanGuiIcerik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FLisan.FieldName,
        TableName + '.' + FKod.FieldName,
        TableName + '.' + FIcerikTipi.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FDeger.FieldName + '::varchar ',
        TableName + '.' + FIsFabrikaAyari.FieldName,
        TableName + '.' + FFormAdi.FieldName
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

procedure TSysLisanGuiIcerik.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FLisan.FieldName,
        FKod.FieldName,
        FIcerikTipi.FieldName,
        FTabloAdi.FieldName,
        FDeger.FieldName,
        FIsFabrikaAyari.FieldName,
        FFormAdi.FieldName
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
    Self.Notify;
  end;
end;

procedure TSysLisanGuiIcerik.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FLisan.FieldName,
        FKod.FieldName,
        FIcerikTipi.FieldName,
        FTabloAdi.FieldName,
        FDeger.FieldName,
        FIsFabrikaAyari.FieldName,
        FFormAdi.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.Notify;
  end;
end;

procedure TSysLisanGuiIcerik.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  vSysLangGuiContent: TSysLisanGuiIcerik;
  vDmpFilter: string;
begin
  vSysLangGuiContent := TSysLisanGuiIcerik.Create(Self.Database);
  try
    if FormatedVariantVal(FTabloAdi.DataType, FTabloAdi.Value) <> '' then
      vDmpFilter := ' AND ' + vSysLangGuiContent.FTabloAdi.QryName + '=' + QuotedStr(FormatedVariantVal(FTabloAdi.DataType, FTabloAdi.Value));

    vSysLangGuiContent.SelectToList(' AND ' + TableName + '.' + FLisan.FieldName + '=' + QuotedStr(FormatedVariantVal(FLisan.DataType, FLisan.Value)) +
                                    ' AND ' + TableName + '.' + FKod.FieldName + '=' + QuotedStr(FormatedVariantVal(FKod.DataType, FKod.Value)) +
                                    ' AND ' + TableName + '.' + FIcerikTipi.FieldName + '=' + QuotedStr(FormatedVariantVal(FIcerikTipi.DataType, FIcerikTipi.Value)) +
                                 vDmpFilter, False, False);
    if vSysLangGuiContent.List.Count = 1 then
    begin
      Self.Id.Value := vSysLangGuiContent.Id.Value;
      Self.Update(False)
    end
    else
      Self.Insert(AID, APermissionControl);
  finally
    vSysLangGuiContent.Free;
  end;
end;

function TSysLisanGuiIcerik.Clone: TTable;
begin
  Result := TSysLisanGuiIcerik.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
