unit Ths.Erp.Database.Table.SysUygulamaAyariDiger;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  /// <summary>
  /// Uygulama i�inde kullan�lacak di�er �zelle�tirme ayarlar� burada kullanabilir.
  /// </summary>
  TSysUygulamaAyariDiger = class(TTable)
  private
    FIsEDefterAktif: TFieldDB;
    FIsEFaturaAktif: TFieldDB;
    FIsEIrsaliyeAktif: TFieldDB;
    FPathGuncelleme: TFieldDB;
    FPathStokResim: TFieldDB;
    FPathUTD: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    /// <summary>
    /// E-Defter kullan�lacaksa bu ayar� a��yoruz. E-Defter ayar�na g�re �zel i�lemler varsa bu ayara bakarak yap�yoruz
    /// </summary>
    Property IsEDefterAktif: TFieldDB read FIsEDefterAktif write FIsEDefterAktif;
    /// <summary>
    /// E-Fatura kullan�lacaksa bu ayar� a��yoruz. E-Fatura ayar�na g�re �zel i�lemler varsa bu ayara bakarak yap�yoruz
    /// </summary>
    Property IsEFaturaAktif: TFieldDB read FIsEFaturaAktif write FIsEFaturaAktif;
    /// <summary>
    /// E-�rsaliye kullan�lacaksa bu ayar� a��yoruz. E-�rsaliye ayar�na g�re �zel i�lemler varsa bu ayara bakarak yap�yoruz
    /// </summary>
    Property IsEIrsaliyeAktif: TFieldDB read FIsEIrsaliyeAktif write FIsEIrsaliyeAktif;
    /// <summary>
    ///  Uygulamada bir g�ncelleme oldu�unda otomatik olarak g�ncelleme alaca�� zaman,
    /// a� �zerinde payla��ma a��lm�� klas�r yolu
    /// </summary>
    Property PathUpdate: TFieldDB read FPathGuncelleme write FPathGuncelleme;
    /// <summary>
    ///  Stok kartlar�nda g�sterilen resimlerin bulundu�u dizin.
    /// A� �zerinde payla��ma a��lm�� klas�r yolu
    /// </summary>
    Property PathStock: TFieldDB read FPathStokResim write FPathStokResim;
    /// <summary>
    ///  �retim Teknik D�k�manlar mod�l� i�in kullan�lan dosyalar�n tutuldu�u yol.
    /// A� �zerinde payla��ma a��lm�� klas�r yolu.
    /// </summary>
    Property PathUTD: TFieldDB read FPathUTD write FPathUTD;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysUygulamaAyariDiger.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_uygulama_ayari_diger';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FIsEDefterAktif := TFieldDB.Create('is_edefter_aktif', ftBoolean, False, Self, 'E-Defter Aktif');
  FIsEFaturaAktif := TFieldDB.Create('is_efatura_aktif', ftBoolean, False, Self, 'E-Fatura Aktif');
  FIsEIrsaliyeAktif := TFieldDB.Create('is_eirsaliye_aktif', ftBoolean, False, Self, 'E-Irsaliye');
  FPathGuncelleme := TFieldDB.Create('path_guncelleme', ftString, '', Self, 'Dosya Yolu G�ncelleme');
  FPathStokResim := TFieldDB.Create('path_stok_resim', ftString, '', Self, 'Dosya Yolu Stok Kart� Resim');
  FPathUTD := TFieldDB.Create('path_utd', ftString, '', Self, 'Dosya Yolu �retim Teknik Dok�man');
end;

procedure TSysUygulamaAyariDiger.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIsEDefterAktif.FieldName,
        TableName + '.' + FIsEFaturaAktif.FieldName,
        TableName + '.' + FIsEIrsaliyeAktif.FieldName,
        TableName + '.' + FPathGuncelleme.FieldName,
        TableName + '.' + FPathStokResim.FieldName,
        TableName + '.' + FPathUTD.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysUygulamaAyariDiger.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FIsEDefterAktif.FieldName,
        TableName + '.' + FIsEFaturaAktif.FieldName,
        TableName + '.' + FIsEIrsaliyeAktif.FieldName,
        TableName + '.' + FPathGuncelleme.FieldName,
        TableName + '.' + FPathStokResim.FieldName,
        TableName + '.' + FPathUTD.FieldName
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

procedure TSysUygulamaAyariDiger.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIsEDefterAktif.FieldName,
        FIsEFaturaAktif.FieldName,
        FIsEIrsaliyeAktif.FieldName,
        FPathGuncelleme.FieldName,
        FPathStokResim.FieldName,
        FPathUTD.FieldName
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

procedure TSysUygulamaAyariDiger.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIsEDefterAktif.FieldName,
        FIsEFaturaAktif.FieldName,
        FIsEIrsaliyeAktif.FieldName,
        FPathGuncelleme.FieldName,
        FPathStokResim.FieldName,
        FPathUTD.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysUygulamaAyariDiger.Clone: TTable;
begin
  Result := TSysUygulamaAyariDiger.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
