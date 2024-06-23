unit Ths.Database.Table.SysKaynaklar;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  Ths.Database, Ths.Database.Table, Ths.Database.Table.SysKaynakGruplari;

type
  TSysKaynak = class(TTable)
  private
    FKaynakKodu: TFieldDB;
    FKaynakAdi: TFieldDB;
    FKaynakGrupID: TFieldDB;
    FKaynakGrubu: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property KaynakKodu: TFieldDB read FKaynakKodu write FKaynakKodu;
    property KaynakAdi: TFieldDB read FKaynakAdi write FKaynakAdi;
    property KaynakGrupID: TFieldDB read FKaynakGrupID write FKaynakGrupID;
    property KaynakGrubu: TFieldDB read FKaynakGrubu write FKaynakGrubu;
  end;

implementation

uses
  Ths.Globals, Ths.Constants, Ths.Database.Table.SysErisimHaklari,
  Ths.Database.Table.SysKullanicilar;

constructor TSysKaynak.Create(ADatabase: TDatabase);
var
  LSysGroup: TSysKaynakGrubu;
begin
  TableName := 'sys_kaynaklar';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  LSysGroup := TSysKaynakGrubu.Create(ADatabase);
  try
    FKaynakKodu := TFieldDB.Create('kaynak_kodu', ftInteger, 0, Self, 'Kaynak Kodu');
    FKaynakAdi := TFieldDB.Create('kaynak_adi', ftString, '', Self, 'Kaynak Adı');
    FKaynakGrupID := TFieldDB.Create('kaynak_grup_id', ftInteger, 0, Self, 'Kaynak Grup ID');
    FKaynakGrubu := TFieldDB.Create(LSysGroup.Grup.FieldName, LSysGroup.Grup.DataType, '', Self, LSysGroup.Grup.Title);
  finally
    LSysGroup.Free;
  end;
end;

procedure TSysKaynak.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LSysGroup: TSysKaynakGrubu;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LSysGroup := TSysKaynakGrubu.Create(Database);
  try
    with QryOfDS do
    begin
      Close;
      Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
        Id.QryName,
        FKaynakGrupID.QryName,
        addLangField(FKaynakGrubu.FieldName),
        FKaynakKodu.QryName,
        addLangField(FKaynakAdi.FieldName, '', True)
      ], [
        addLeftJoin(FKaynakGrubu.FieldName, FKaynakGrupID.FieldName, LSysGroup.TableName),
        addLeftJoin(FKaynakAdi.FieldName, FKaynakAdi.FieldName, TableName, True),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  finally
    LSysGroup.Free;
  end;
end;

procedure TSysKaynak.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
  LSysGroup: TSysKaynakGrubu;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  LSysGroup := TSysKaynakGrubu.Create(Database);
  try
    with LQry do
    begin
      Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
        Id.QryName,
        FKaynakGrupID.QryName,
        addLangField(FKaynakGrubu.FieldName),
        FKaynakKodu.QryName,
        addLangField(FKaynakAdi.FieldName, '', True)
      ], [
        addLeftJoin(FKaynakGrubu.FieldName, FKaynakGrupID.FieldName, LSysGroup.TableName),
        addLeftJoin(FKaynakAdi.FieldName, FKaynakAdi.FieldName, TableName, True),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(LQry);

        List.Add(Clone);

        Next;
      end;
    end;
  finally
    Free;
    LSysGroup.Free;
  end;
end;

procedure TSysKaynak.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FKaynakKodu.FieldName,
      FKaynakAdi.FieldName,
      FKaynakGrupID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysKaynak.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FKaynakKodu.FieldName,
      FKaynakAdi.FieldName,
      FKaynakGrupID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TSysKaynak.BusinessInsert(APermissionControl: Boolean);
var
  LRights: TSysErisimHakki;
  LQry: TFDQuery;
begin
  Insert(APermissionControl);
  LRights := TSysErisimHakki.Create(Database);
  LQry := Ths.Globals.GDataBase.NewQuery();
  try
    LQry.SQL.Text :=
      'INSERT INTO ' + LRights.TableName + ' (' +
        LRights.KaynakID.FieldName + ', ' +
        LRights.IsOkuma.FieldName + ', ' +
        LRights.IsEkleme.FieldName + ', ' +
        LRights.IsGuncelleme.FieldName + ', ' +
        LRights.IsSilme.FieldName + ', ' +
        LRights.IsOzel.FieldName + ', ' +
        LRights.KullaniciID.FieldName + ') ' +
      '(SELECT ' +
        IntToStr(Self.Id.Value) +
        ', false, false, false, false, false, ' +
        GSysKullanici.Id.QryName +
      ' FROM ' + GSysKullanici.TableName + ')';
    LQry.ExecSQL;

  finally
    LRights.Free;
    LQry.Free;
  end;
end;

function TSysKaynak.Clone: TTable;
begin
  Result := TSysKaynak.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
