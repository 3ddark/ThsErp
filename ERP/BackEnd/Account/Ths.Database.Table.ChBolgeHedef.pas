unit Ths.Erp.Database.Table.ChBolgeHedef;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table

  , Ths.Erp.Database.Table.ChBolgeTuru
  , Ths.Erp.Database.Table.ChBolge
  ;

type
  TChBolgeHedef = class(TTable)
  private
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
    FParaBirimi: TFieldDB;
    FHedefOcak: TFieldDB;
    FHedefSubat: TFieldDB;
    FHedefMart: TFieldDB;
    FHedefNisan: TFieldDB;
    FHedefMayis: TFieldDB;
    FHedefHaziran: TFieldDB;
    FHedefTemmuz: TFieldDB;
    FHedefAgustos: TFieldDB;
    FHedefEylul: TFieldDB;
    FHedefEkim: TFieldDB;
    FHedefKasim: TFieldDB;
    FHedefAralik: TFieldDB;
    FHedefHamOcak: TFieldDB;
    FHedefHamSubat: TFieldDB;
    FHedefHamMart: TFieldDB;
    FHedefHamNisan: TFieldDB;
    FHedefHamMayis: TFieldDB;
    FHedefHamHaziran: TFieldDB;
    FHedefHamTemmuz: TFieldDB;
    FHedefHamAgustos: TFieldDB;
    FHedefHamEylul: TFieldDB;
    FHedefHamEkim: TFieldDB;
    FHedefHamKasim: TFieldDB;
    FHedefHamAralik: TFieldDB;
    FGecenOcak: TFieldDB;
    FGecenSubat: TFieldDB;
    FGecenMart: TFieldDB;
    FGecenNisan: TFieldDB;
    FGecenMayis: TFieldDB;
    FGecenHaziran: TFieldDB;
    FGecenTemmuz: TFieldDB;
    FGecenAgustos: TFieldDB;
    FGecenEylul: TFieldDB;
    FGecenEkim: TFieldDB;
    FGecenKasim: TFieldDB;
    FGecenAralik: TFieldDB;
    FGecenHamOcak: TFieldDB;
    FGecenHamSubat: TFieldDB;
    FGecenHamMart: TFieldDB;
    FGecenHamNisan: TFieldDB;
    FGecenHamMayis: TFieldDB;
    FGecenHamHaziran: TFieldDB;
    FGecenHamTemmuz: TFieldDB;
    FGecenHamAgustos: TFieldDB;
    FGecenHamEylul: TFieldDB;
    FGecenHamEkim: TFieldDB;
    FGecenHamKasim: TFieldDB;
    FGecenHamAralik: TFieldDB;

    FBolgeler: TChBolge;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;
    destructor Destroy; override;

    Property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    Property Bolge: TFieldDB read FBolge write FBolge;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property HedefOcak: TFieldDB read FHedefOcak write FHedefOcak;
    Property HedefSubat: TFieldDB read FHedefSubat write FHedefSubat;
    Property HedefMart: TFieldDB read FHedefMart write FHedefMart;
    Property HedefNisan: TFieldDB read FHedefNisan write FHedefNisan;
    Property HedefMayis: TFieldDB read FHedefMayis write FHedefMayis;
    Property HedefHaziran: TFieldDB read FHedefHaziran write FHedefHaziran;
    Property HedefTemmuz: TFieldDB read FHedefTemmuz write FHedefTemmuz;
    Property HedefAgustos: TFieldDB read FHedefAgustos write FHedefAgustos;
    Property HedefEylul: TFieldDB read FHedefEylul write FHedefEylul;
    Property HedefEkim: TFieldDB read FHedefEkim write FHedefEkim;
    Property HedefKasim: TFieldDB read FHedefKasim write FHedefKasim;
    Property HedefAralik: TFieldDB read FHedefAralik write FHedefAralik;
    Property HedefHamOcak: TFieldDB read FHedefHamOcak write FHedefHamOcak;
    Property HedefHamSubat: TFieldDB read FHedefHamSubat write FHedefHamSubat;
    Property HedefHamMart: TFieldDB read FHedefHamMart write FHedefHamMart;
    Property HedefHamNisan: TFieldDB read FHedefHamNisan write FHedefHamNisan;
    Property HedefHamMayis: TFieldDB read FHedefHamMayis write FHedefHamMayis;
    Property HedefHamHaziran: TFieldDB read FHedefHamHaziran write FHedefHamHaziran;
    Property HedefHamTemmuz: TFieldDB read FHedefHamTemmuz write FHedefHamTemmuz;
    Property HedefHamAgustos: TFieldDB read FHedefHamAgustos write FHedefHamAgustos;
    Property HedefHamEylul: TFieldDB read FHedefHamEylul write FHedefHamEylul;
    Property HedefHamEkim: TFieldDB read FHedefHamEkim write FHedefHamEkim;
    Property HedefHamKasim: TFieldDB read FHedefHamKasim write FHedefHamKasim;
    Property HedefHamAralik: TFieldDB read FHedefHamAralik write FHedefHamAralik;
    Property GecenOcak: TFieldDB read FGecenOcak write FGecenOcak;
    Property GecenSubat: TFieldDB read FGecenSubat write FGecenSubat;
    Property GecenMart: TFieldDB read FGecenMart write FGecenMart;
    Property GecenNisan: TFieldDB read FGecenNisan write FGecenNisan;
    Property GecenMayis: TFieldDB read FGecenMayis write FGecenMayis;
    Property GecenHaziran: TFieldDB read FGecenHaziran write FGecenHaziran;
    Property GecenTemmuz: TFieldDB read FGecenTemmuz write FGecenTemmuz;
    Property GecenAgustos: TFieldDB read FGecenAgustos write FGecenAgustos;
    Property GecenEylul: TFieldDB read FGecenEylul write FGecenEylul;
    Property GecenEkim: TFieldDB read FGecenEkim write FGecenEkim;
    Property GecenKasim: TFieldDB read FGecenKasim write FGecenKasim;
    Property GecenAralik: TFieldDB read FGecenAralik write FGecenAralik;
    Property GecenHamOcak: TFieldDB read FGecenHamOcak write FGecenHamOcak;
    Property GecenHamSubat: TFieldDB read FGecenHamSubat write FGecenHamSubat;
    Property GecenHamMart: TFieldDB read FGecenHamMart write FGecenHamMart;
    Property GecenHamNisan: TFieldDB read FGecenHamNisan write FGecenHamNisan;
    Property GecenHamMayis: TFieldDB read FGecenHamMayis write FGecenHamMayis;
    Property GecenHamHaziran: TFieldDB read FGecenHamHaziran write FGecenHamHaziran;
    Property GecenHamTemmuz: TFieldDB read FGecenHamTemmuz write FGecenHamTemmuz;
    Property GecenHamAgustos: TFieldDB read FGecenHamAgustos write FGecenHamAgustos;
    Property GecenHamEylul: TFieldDB read FGecenHamEylul write FGecenHamEylul;
    Property GecenHamEkim: TFieldDB read FGecenHamEkim write FGecenHamEkim;
    Property GecenHamKasim: TFieldDB read FGecenHamKasim write FGecenHamKasim;
    Property GecenHamAralik: TFieldDB read FGecenHamAralik write FGecenHamAralik;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TChBolgeHedef.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'ch_bolge_hedef';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FBolgeler := TChBolge.Create(Database);

  FBolgeID := TFieldDB.Create('bolge_id', ftInteger, 0, Self, 'Bölge ID');
  FBolge := TFieldDB.Create(FBolgeler.Bolge.FieldName, FBolgeler.Bolge.DataType, '', Self, 'Bölge');
  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, 'Para Birimi');
  FHedefOcak := TFieldDB.Create('hedef_ocak', ftBCD, 0, Self, 'Hedef Ocak');
  FHedefSubat := TFieldDB.Create('hedef_subat', ftBCD, 0, Self, 'Hedef Þubat');
  FHedefMart := TFieldDB.Create('hedef_mart', ftBCD, 0, Self, 'Hedef Mart');
  FHedefNisan := TFieldDB.Create('hedef_nisan', ftBCD, 0, Self, 'Hedef Nisan');
  FHedefMayis := TFieldDB.Create('hedef_mayis', ftBCD, 0, Self, 'Hedef Mayýs');
  FHedefHaziran := TFieldDB.Create('hedef_haziran', ftBCD, 0, Self, 'Hedef Haziran');
  FHedefTemmuz := TFieldDB.Create('hedef_temmuz', ftBCD, 0, Self, 'Hedef Temmuz');
  FHedefAgustos := TFieldDB.Create('hedef_agustos', ftBCD, 0, Self, 'Hedef Aðustos');
  FHedefEylul := TFieldDB.Create('hedef_eylul', ftBCD, 0, Self, 'Hedef Eylül');
  FHedefEkim := TFieldDB.Create('hedef_ekim', ftBCD, 0, Self, 'Hedef Ekim');
  FHedefKasim := TFieldDB.Create('hedef_kasim', ftBCD, 0, Self, 'Hedef Kasým');
  FHedefAralik := TFieldDB.Create('hedef_aralik', ftBCD, 0, Self, 'Hedef Aralýk');
  FHedefHamOcak := TFieldDB.Create('hedef_ham_ocak', ftBCD, 0, Self, '');
  FHedefHamSubat := TFieldDB.Create('hedef_ham_subat', ftBCD, 0, Self, '');
  FHedefHamMart := TFieldDB.Create('hedef_ham_mart', ftBCD, 0, Self, '');
  FHedefHamNisan := TFieldDB.Create('hedef_ham_nisan', ftBCD, 0, Self, '');
  FHedefHamMayis := TFieldDB.Create('hedef_ham_mayis', ftBCD, 0, Self, '');
  FHedefHamHaziran := TFieldDB.Create('hedef_ham_haziran', ftBCD, 0, Self, '');
  FHedefHamTemmuz := TFieldDB.Create('hedef_ham_temmuz', ftBCD, 0, Self, '');
  FHedefHamAgustos := TFieldDB.Create('hedef_ham_agustos', ftBCD, 0, Self, '');
  FHedefHamEylul := TFieldDB.Create('hedef_ham_eylul', ftBCD, 0, Self, '');
  FHedefHamEkim := TFieldDB.Create('hedef_ham_ekim', ftBCD, 0, Self, '');
  FHedefHamKasim := TFieldDB.Create('hedef_ham_kasim', ftBCD, 0, Self, '');
  FHedefHamAralik := TFieldDB.Create('hedef_ham_aralik', ftBCD, 0, Self, '');
  FGecenOcak := TFieldDB.Create('gecen_ocak', ftBCD, 0, Self, '');
  FGecenSubat := TFieldDB.Create('gecen_subat', ftBCD, 0, Self, '');
  FGecenMart := TFieldDB.Create('gecen_mart', ftBCD, 0, Self, '');
  FGecenNisan := TFieldDB.Create('gecen_nisan', ftBCD, 0, Self, '');
  FGecenMayis := TFieldDB.Create('gecen_mayis', ftBCD, 0, Self, '');
  FGecenHaziran := TFieldDB.Create('gecen_haziran', ftBCD, 0, Self, '');
  FGecenTemmuz := TFieldDB.Create('gecen_temmuz', ftBCD, 0, Self, '');
  FGecenAgustos := TFieldDB.Create('gecen_agustos', ftBCD, 0, Self, '');
  FGecenEylul := TFieldDB.Create('gecen_eylul', ftBCD, 0, Self, '');
  FGecenEkim := TFieldDB.Create('gecen_ekim', ftBCD, 0, Self, '');
  FGecenKasim := TFieldDB.Create('gecen_kasim', ftBCD, 0, Self, '');
  FGecenAralik := TFieldDB.Create('gecen_aralik', ftBCD, 0, Self, '');
  FGecenHamOcak := TFieldDB.Create('gecen_ham_ocak', ftBCD, 0, Self, '');
  FGecenHamSubat := TFieldDB.Create('gecen_ham_subat', ftBCD, 0, Self, '');
  FGecenHamMart := TFieldDB.Create('gecen_ham_mart', ftBCD, 0, Self, '');
  FGecenHamNisan := TFieldDB.Create('gecen_ham_nisan', ftBCD, 0, Self, '');
  FGecenHamMayis := TFieldDB.Create('gecen_ham_mayis', ftBCD, 0, Self, '');
  FGecenHamHaziran := TFieldDB.Create('gecen_ham_haziran', ftBCD, 0, Self, '');
  FGecenHamTemmuz := TFieldDB.Create('gecen_ham_temmuz', ftBCD, 0, Self, '');
  FGecenHamAgustos := TFieldDB.Create('gecen_ham_agustos', ftBCD, 0, Self, '');
  FGecenHamEylul := TFieldDB.Create('gecen_ham_eylul', ftBCD, 0, Self, '');
  FGecenHamEkim := TFieldDB.Create('gecen_ham_ekim', ftBCD, 0, Self, '');
  FGecenHamKasim := TFieldDB.Create('gecen_ham_kasim', ftBCD, 0, Self, '');
  FGecenHamAralik := TFieldDB.Create('gecen_ham_aralik', ftBCD, 0, Self, '');
end;

destructor TChBolgeHedef.Destroy;
begin
  FBolgeler.Free;
  inherited;
end;

procedure TChBolgeHedef.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FBolgeID.FieldName,
        addLangField(FBolge.FieldName),
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FHedefOcak.FieldName,
        TableName + '.' + FHedefSubat.FieldName,
        TableName + '.' + FHedefMart.FieldName,
        TableName + '.' + FHedefNisan.FieldName,
        TableName + '.' + FHedefMayis.FieldName,
        TableName + '.' + FHedefHaziran.FieldName,
        TableName + '.' + FHedefTemmuz.FieldName,
        TableName + '.' + FHedefAgustos.FieldName,
        TableName + '.' + FHedefEylul.FieldName,
        TableName + '.' + FHedefEkim.FieldName,
        TableName + '.' + FHedefKasim.FieldName,
        TableName + '.' + FHedefAralik.FieldName,
        TableName + '.' + FHedefHamOcak.FieldName,
        TableName + '.' + FHedefHamSubat.FieldName,
        TableName + '.' + FHedefHamMart.FieldName,
        TableName + '.' + FHedefHamNisan.FieldName,
        TableName + '.' + FHedefHamMayis.FieldName,
        TableName + '.' + FHedefHamHaziran.FieldName,
        TableName + '.' + FHedefHamTemmuz.FieldName,
        TableName + '.' + FHedefHamAgustos.FieldName,
        TableName + '.' + FHedefHamEylul.FieldName,
        TableName + '.' + FHedefHamEkim.FieldName,
        TableName + '.' + FHedefHamKasim.FieldName,
        TableName + '.' + FHedefHamAralik.FieldName,
        TableName + '.' + FGecenOcak.FieldName,
        TableName + '.' + FGecenSubat.FieldName,
        TableName + '.' + FGecenMart.FieldName,
        TableName + '.' + FGecenNisan.FieldName,
        TableName + '.' + FGecenMayis.FieldName,
        TableName + '.' + FGecenHaziran.FieldName,
        TableName + '.' + FGecenTemmuz.FieldName,
        TableName + '.' + FGecenAgustos.FieldName,
        TableName + '.' + FGecenEylul.FieldName,
        TableName + '.' + FGecenEkim.FieldName,
        TableName + '.' + FGecenKasim.FieldName,
        TableName + '.' + FGecenAralik.FieldName,
        TableName + '.' + FGecenHamOcak.FieldName,
        TableName + '.' + FGecenHamSubat.FieldName,
        TableName + '.' + FGecenHamMart.FieldName,
        TableName + '.' + FGecenHamNisan.FieldName,
        TableName + '.' + FGecenHamMayis.FieldName,
        TableName + '.' + FGecenHamHaziran.FieldName,
        TableName + '.' + FGecenHamTemmuz.FieldName,
        TableName + '.' + FGecenHamAgustos.FieldName,
        TableName + '.' + FGecenHamEylul.FieldName,
        TableName + '.' + FGecenHamEkim.FieldName,
        TableName + '.' + FGecenHamKasim.FieldName,
        TableName + '.' + FGecenHamAralik.FieldName
      ], [
        addLeftJoin(FBolge.FieldName, FBolgeID.FieldName, FBolgeler.TableName),
        'WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FBolgeID, 'Bölge ID', QueryOfDS);
      setFieldTitle(FBolge, 'Bölge', QueryOfDS);
      setFieldTitle(FParaBirimi, 'Para Birimi', QueryOfDS);
      setFieldTitle(FHedefOcak, 'Hedef Ocak', QueryOfDS);
      setFieldTitle(FHedefSubat, 'Hedef Þubat', QueryOfDS);
      setFieldTitle(FHedefMart, 'Hedef Mart', QueryOfDS);
      setFieldTitle(FHedefNisan, 'Hedef Nisan', QueryOfDS);
      setFieldTitle(FHedefMayis, 'Hedef Mayýs', QueryOfDS);
      setFieldTitle(FHedefHaziran, 'Hedef Haziran', QueryOfDS);
      setFieldTitle(FHedefTemmuz, 'Hedef Temmuz', QueryOfDS);
      setFieldTitle(FHedefAgustos, 'Hedef Aðustos', QueryOfDS);
      setFieldTitle(FHedefEylul, 'Hedef Eylül', QueryOfDS);
      setFieldTitle(FHedefEkim, 'Hedef Ekim', QueryOfDS);
      setFieldTitle(FHedefKasim, 'Hedef Kasým', QueryOfDS);
      setFieldTitle(FHedefAralik, 'Hedef Aralýk', QueryOfDS);
      setFieldTitle(FHedefHamOcak, 'Hedef Mamül/Hammadde Ocak', QueryOfDS);
      setFieldTitle(FHedefHamSubat, 'Hedef Mamül/Hammadde Þubat', QueryOfDS);
      setFieldTitle(FHedefHamMart, 'Hedef Mamül/Hammadde Mart', QueryOfDS);
      setFieldTitle(FHedefHamNisan, 'Hedef Mamül/Hammadde Nisan', QueryOfDS);
      setFieldTitle(FHedefHamMayis, 'Hedef Mamül/Hammadde Mayýs', QueryOfDS);
      setFieldTitle(FHedefHamHaziran, 'Hedef Mamül/Hammadde Haziran', QueryOfDS);
      setFieldTitle(FHedefHamTemmuz, 'Hedef Mamül/Hammadde Temmuz', QueryOfDS);
      setFieldTitle(FHedefHamAgustos, 'Hedef Mamül/Hammadde Aðustos', QueryOfDS);
      setFieldTitle(FHedefHamEylul, 'Hedef Mamül/Hammadde Eylül', QueryOfDS);
      setFieldTitle(FHedefHamEkim, 'Hedef Mamül/Hammadde Ekim', QueryOfDS);
      setFieldTitle(FHedefHamKasim, 'Hedef Mamül/Hammadde Kasým', QueryOfDS);
      setFieldTitle(FHedefHamAralik, 'Hedef Mamül/Hammadde Aralýk', QueryOfDS);
      setFieldTitle(FGecenOcak, 'Geçmiþ Ocak', QueryOfDS);
      setFieldTitle(FGecenSubat, 'Geçmiþ Þubat', QueryOfDS);
      setFieldTitle(FGecenMart, 'Geçmiþ Mart', QueryOfDS);
      setFieldTitle(FGecenNisan, 'Geçmiþ Nisan', QueryOfDS);
      setFieldTitle(FGecenMayis, 'Geçmiþ Mayýs', QueryOfDS);
      setFieldTitle(FGecenHaziran, 'Geçmiþ Haziran', QueryOfDS);
      setFieldTitle(FGecenTemmuz, 'Geçmiþ Temmuz', QueryOfDS);
      setFieldTitle(FGecenAgustos, 'Geçmiþ Aðustos', QueryOfDS);
      setFieldTitle(FGecenEylul, 'Geçmiþ Eylül', QueryOfDS);
      setFieldTitle(FGecenEkim, 'Geçmiþ Ekim', QueryOfDS);
      setFieldTitle(FGecenKasim, 'Geçmiþ Kasým', QueryOfDS);
      setFieldTitle(FGecenAralik, 'Geçmiþ Aralýk', QueryOfDS);
      setFieldTitle(FGecenHamOcak, 'Geçmiþ Mamül/Hammadde Ocak', QueryOfDS);
      setFieldTitle(FGecenHamSubat, 'Geçmiþ Mamül/Hammadde Þubat', QueryOfDS);
      setFieldTitle(FGecenHamMart, 'Geçmiþ Mamül/Hammadde Mart', QueryOfDS);
      setFieldTitle(FGecenHamNisan, 'Geçmiþ Mamül/Hammadde Nisan', QueryOfDS);
      setFieldTitle(FGecenHamMayis, 'Geçmiþ Mamül/Hammadde Mayýs', QueryOfDS);
      setFieldTitle(FGecenHamHaziran, 'Geçmiþ Mamül/Hammadde Haziran', QueryOfDS);
      setFieldTitle(FGecenHamTemmuz, 'Geçmiþ Mamül/Hammadde Temmuz', QueryOfDS);
      setFieldTitle(FGecenHamAgustos, 'Geçmiþ Mamül/Hammadde Aðustos', QueryOfDS);
      setFieldTitle(FGecenHamEylul, 'Geçmiþ Mamül/Hammadde Eylül', QueryOfDS);
      setFieldTitle(FGecenHamEkim, 'Geçmiþ Mamül/Hammadde Ekim', QueryOfDS);
      setFieldTitle(FGecenHamKasim, 'Geçmiþ Mamül/Hammadde Kasým', QueryOfDS);
      setFieldTitle(FGecenHamAralik, 'Geçmiþ Mamül/Hammadde Aralýk', QueryOfDS);
    end;
  end;
end;

procedure TChBolgeHedef.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    if (pLock) then
		  pFilter := pFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FBolgeID.FieldName,
        addLangField(FBolge.FieldName),
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FHedefOcak.FieldName,
        TableName + '.' + FHedefSubat.FieldName,
        TableName + '.' + FHedefMart.FieldName,
        TableName + '.' + FHedefNisan.FieldName,
        TableName + '.' + FHedefMayis.FieldName,
        TableName + '.' + FHedefHaziran.FieldName,
        TableName + '.' + FHedefTemmuz.FieldName,
        TableName + '.' + FHedefAgustos.FieldName,
        TableName + '.' + FHedefEylul.FieldName,
        TableName + '.' + FHedefEkim.FieldName,
        TableName + '.' + FHedefKasim.FieldName,
        TableName + '.' + FHedefAralik.FieldName,
        TableName + '.' + FHedefHamOcak.FieldName,
        TableName + '.' + FHedefHamSubat.FieldName,
        TableName + '.' + FHedefHamMart.FieldName,
        TableName + '.' + FHedefHamNisan.FieldName,
        TableName + '.' + FHedefHamMayis.FieldName,
        TableName + '.' + FHedefHamHaziran.FieldName,
        TableName + '.' + FHedefHamTemmuz.FieldName,
        TableName + '.' + FHedefHamAgustos.FieldName,
        TableName + '.' + FHedefHamEylul.FieldName,
        TableName + '.' + FHedefHamEkim.FieldName,
        TableName + '.' + FHedefHamKasim.FieldName,
        TableName + '.' + FHedefHamAralik.FieldName,
        TableName + '.' + FGecenOcak.FieldName,
        TableName + '.' + FGecenSubat.FieldName,
        TableName + '.' + FGecenMart.FieldName,
        TableName + '.' + FGecenNisan.FieldName,
        TableName + '.' + FGecenMayis.FieldName,
        TableName + '.' + FGecenHaziran.FieldName,
        TableName + '.' + FGecenTemmuz.FieldName,
        TableName + '.' + FGecenAgustos.FieldName,
        TableName + '.' + FGecenEylul.FieldName,
        TableName + '.' + FGecenEkim.FieldName,
        TableName + '.' + FGecenKasim.FieldName,
        TableName + '.' + FGecenAralik.FieldName,
        TableName + '.' + FGecenHamOcak.FieldName,
        TableName + '.' + FGecenHamSubat.FieldName,
        TableName + '.' + FGecenHamMart.FieldName,
        TableName + '.' + FGecenHamNisan.FieldName,
        TableName + '.' + FGecenHamMayis.FieldName,
        TableName + '.' + FGecenHamHaziran.FieldName,
        TableName + '.' + FGecenHamTemmuz.FieldName,
        TableName + '.' + FGecenHamAgustos.FieldName,
        TableName + '.' + FGecenHamEylul.FieldName,
        TableName + '.' + FGecenHamEkim.FieldName,
        TableName + '.' + FGecenHamKasim.FieldName,
        TableName + '.' + FGecenHamAralik.FieldName
      ], [
        addLeftJoin(FBolge.FieldName, FBolgeID.FieldName, FBolgeler.TableName),
        'WHERE 1=1 ', pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FBolgeID, QueryOfList);
        setFieldValue(FBolge, QueryOfList);
        setFieldValue(FParaBirimi, QueryOfList);
        setFieldValue(FHedefOcak, QueryOfList);
        setFieldValue(FHedefSubat, QueryOfList);
        setFieldValue(FHedefMart, QueryOfList);
        setFieldValue(FHedefNisan, QueryOfList);
        setFieldValue(FHedefMayis, QueryOfList);
        setFieldValue(FHedefHaziran, QueryOfList);
        setFieldValue(FHedefTemmuz, QueryOfList);
        setFieldValue(FHedefAgustos, QueryOfList);
        setFieldValue(FHedefEylul, QueryOfList);
        setFieldValue(FHedefEkim, QueryOfList);
        setFieldValue(FHedefKasim, QueryOfList);
        setFieldValue(FHedefAralik, QueryOfList);
        setFieldValue(FHedefHamOcak, QueryOfList);
        setFieldValue(FHedefHamSubat, QueryOfList);
        setFieldValue(FHedefHamMart, QueryOfList);
        setFieldValue(FHedefHamNisan, QueryOfList);
        setFieldValue(FHedefHamMayis, QueryOfList);
        setFieldValue(FHedefHamHaziran, QueryOfList);
        setFieldValue(FHedefHamTemmuz, QueryOfList);
        setFieldValue(FHedefHamAgustos, QueryOfList);
        setFieldValue(FHedefHamEylul, QueryOfList);
        setFieldValue(FHedefHamEkim, QueryOfList);
        setFieldValue(FHedefHamKasim, QueryOfList);
        setFieldValue(FHedefHamAralik, QueryOfList);
        setFieldValue(FGecenOcak, QueryOfList);
        setFieldValue(FGecenSubat, QueryOfList);
        setFieldValue(FGecenMart, QueryOfList);
        setFieldValue(FGecenNisan, QueryOfList);
        setFieldValue(FGecenMayis, QueryOfList);
        setFieldValue(FGecenHaziran, QueryOfList);
        setFieldValue(FGecenTemmuz, QueryOfList);
        setFieldValue(FGecenAgustos, QueryOfList);
        setFieldValue(FGecenEylul, QueryOfList);
        setFieldValue(FGecenEkim, QueryOfList);
        setFieldValue(FGecenKasim, QueryOfList);
        setFieldValue(FGecenAralik, QueryOfList);
        setFieldValue(FGecenHamOcak, QueryOfList);
        setFieldValue(FGecenHamSubat, QueryOfList);
        setFieldValue(FGecenHamMart, QueryOfList);
        setFieldValue(FGecenHamNisan, QueryOfList);
        setFieldValue(FGecenHamMayis, QueryOfList);
        setFieldValue(FGecenHamHaziran, QueryOfList);
        setFieldValue(FGecenHamTemmuz, QueryOfList);
        setFieldValue(FGecenHamAgustos, QueryOfList);
        setFieldValue(FGecenHamEylul, QueryOfList);
        setFieldValue(FGecenHamEkim, QueryOfList);
        setFieldValue(FGecenHamKasim, QueryOfList);
        setFieldValue(FGecenHamAralik, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TChBolgeHedef.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FBolgeID.FieldName,
        FParaBirimi.FieldName,
        FHedefOcak.FieldName,
        FHedefSubat.FieldName,
        FHedefMart.FieldName,
        FHedefNisan.FieldName,
        FHedefMayis.FieldName,
        FHedefHaziran.FieldName,
        FHedefTemmuz.FieldName,
        FHedefAgustos.FieldName,
        FHedefEylul.FieldName,
        FHedefEkim.FieldName,
        FHedefKasim.FieldName,
        FHedefAralik.FieldName,
        FHedefHamOcak.FieldName,
        FHedefHamSubat.FieldName,
        FHedefHamMart.FieldName,
        FHedefHamNisan.FieldName,
        FHedefHamMayis.FieldName,
        FHedefHamHaziran.FieldName,
        FHedefHamTemmuz.FieldName,
        FHedefHamAgustos.FieldName,
        FHedefHamEylul.FieldName,
        FHedefHamEkim.FieldName,
        FHedefHamKasim.FieldName,
        FHedefHamAralik.FieldName,
        FGecenOcak.FieldName,
        FGecenSubat.FieldName,
        FGecenMart.FieldName,
        FGecenNisan.FieldName,
        FGecenMayis.FieldName,
        FGecenHaziran.FieldName,
        FGecenTemmuz.FieldName,
        FGecenAgustos.FieldName,
        FGecenEylul.FieldName,
        FGecenEkim.FieldName,
        FGecenKasim.FieldName,
        FGecenAralik.FieldName,
        FGecenHamOcak.FieldName,
        FGecenHamSubat.FieldName,
        FGecenHamMart.FieldName,
        FGecenHamNisan.FieldName,
        FGecenHamMayis.FieldName,
        FGecenHamHaziran.FieldName,
        FGecenHamTemmuz.FieldName,
        FGecenHamAgustos.FieldName,
        FGecenHamEylul.FieldName,
        FGecenHamEkim.FieldName,
        FGecenHamKasim.FieldName,
        FGecenHamAralik.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FBolgeID);
      NewParamForQuery(QueryOfInsert, FParaBirimi);
      NewParamForQuery(QueryOfInsert, FHedefOcak);
      NewParamForQuery(QueryOfInsert, FHedefSubat);
      NewParamForQuery(QueryOfInsert, FHedefMart);
      NewParamForQuery(QueryOfInsert, FHedefNisan);
      NewParamForQuery(QueryOfInsert, FHedefMayis);
      NewParamForQuery(QueryOfInsert, FHedefHaziran);
      NewParamForQuery(QueryOfInsert, FHedefTemmuz);
      NewParamForQuery(QueryOfInsert, FHedefAgustos);
      NewParamForQuery(QueryOfInsert, FHedefEylul);
      NewParamForQuery(QueryOfInsert, FHedefEkim);
      NewParamForQuery(QueryOfInsert, FHedefKasim);
      NewParamForQuery(QueryOfInsert, FHedefAralik);
      NewParamForQuery(QueryOfInsert, FHedefHamOcak);
      NewParamForQuery(QueryOfInsert, FHedefHamSubat);
      NewParamForQuery(QueryOfInsert, FHedefHamMart);
      NewParamForQuery(QueryOfInsert, FHedefHamNisan);
      NewParamForQuery(QueryOfInsert, FHedefHamMayis);
      NewParamForQuery(QueryOfInsert, FHedefHamHaziran);
      NewParamForQuery(QueryOfInsert, FHedefHamTemmuz);
      NewParamForQuery(QueryOfInsert, FHedefHamAgustos);
      NewParamForQuery(QueryOfInsert, FHedefHamEylul);
      NewParamForQuery(QueryOfInsert, FHedefHamEkim);
      NewParamForQuery(QueryOfInsert, FHedefHamKasim);
      NewParamForQuery(QueryOfInsert, FHedefHamAralik);
      NewParamForQuery(QueryOfInsert, FGecenOcak);
      NewParamForQuery(QueryOfInsert, FGecenSubat);
      NewParamForQuery(QueryOfInsert, FGecenMart);
      NewParamForQuery(QueryOfInsert, FGecenNisan);
      NewParamForQuery(QueryOfInsert, FGecenMayis);
      NewParamForQuery(QueryOfInsert, FGecenHaziran);
      NewParamForQuery(QueryOfInsert, FGecenTemmuz);
      NewParamForQuery(QueryOfInsert, FGecenAgustos);
      NewParamForQuery(QueryOfInsert, FGecenEylul);
      NewParamForQuery(QueryOfInsert, FGecenEkim);
      NewParamForQuery(QueryOfInsert, FGecenKasim);
      NewParamForQuery(QueryOfInsert, FGecenAralik);
      NewParamForQuery(QueryOfInsert, FGecenHamOcak);
      NewParamForQuery(QueryOfInsert, FGecenHamSubat);
      NewParamForQuery(QueryOfInsert, FGecenHamMart);
      NewParamForQuery(QueryOfInsert, FGecenHamNisan);
      NewParamForQuery(QueryOfInsert, FGecenHamMayis);
      NewParamForQuery(QueryOfInsert, FGecenHamHaziran);
      NewParamForQuery(QueryOfInsert, FGecenHamTemmuz);
      NewParamForQuery(QueryOfInsert, FGecenHamAgustos);
      NewParamForQuery(QueryOfInsert, FGecenHamEylul);
      NewParamForQuery(QueryOfInsert, FGecenHamEkim);
      NewParamForQuery(QueryOfInsert, FGecenHamKasim);
      NewParamForQuery(QueryOfInsert, FGecenHamAralik);

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        pID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        pID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TChBolgeHedef.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FBolgeID.FieldName,
        FParaBirimi.FieldName,
        FHedefOcak.FieldName,
        FHedefSubat.FieldName,
        FHedefMart.FieldName,
        FHedefNisan.FieldName,
        FHedefMayis.FieldName,
        FHedefHaziran.FieldName,
        FHedefTemmuz.FieldName,
        FHedefAgustos.FieldName,
        FHedefEylul.FieldName,
        FHedefEkim.FieldName,
        FHedefKasim.FieldName,
        FHedefAralik.FieldName,
        FHedefHamOcak.FieldName,
        FHedefHamSubat.FieldName,
        FHedefHamMart.FieldName,
        FHedefHamNisan.FieldName,
        FHedefHamMayis.FieldName,
        FHedefHamHaziran.FieldName,
        FHedefHamTemmuz.FieldName,
        FHedefHamAgustos.FieldName,
        FHedefHamEylul.FieldName,
        FHedefHamEkim.FieldName,
        FHedefHamKasim.FieldName,
        FHedefHamAralik.FieldName,
        FGecenOcak.FieldName,
        FGecenSubat.FieldName,
        FGecenMart.FieldName,
        FGecenNisan.FieldName,
        FGecenMayis.FieldName,
        FGecenHaziran.FieldName,
        FGecenTemmuz.FieldName,
        FGecenAgustos.FieldName,
        FGecenEylul.FieldName,
        FGecenEkim.FieldName,
        FGecenKasim.FieldName,
        FGecenAralik.FieldName,
        FGecenHamOcak.FieldName,
        FGecenHamSubat.FieldName,
        FGecenHamMart.FieldName,
        FGecenHamNisan.FieldName,
        FGecenHamMayis.FieldName,
        FGecenHamHaziran.FieldName,
        FGecenHamTemmuz.FieldName,
        FGecenHamAgustos.FieldName,
        FGecenHamEylul.FieldName,
        FGecenHamEkim.FieldName,
        FGecenHamKasim.FieldName,
        FGecenHamAralik.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FBolgeID);
      NewParamForQuery(QueryOfUpdate, FParaBirimi);
      NewParamForQuery(QueryOfUpdate, FHedefOcak);
      NewParamForQuery(QueryOfUpdate, FHedefSubat);
      NewParamForQuery(QueryOfUpdate, FHedefMart);
      NewParamForQuery(QueryOfUpdate, FHedefNisan);
      NewParamForQuery(QueryOfUpdate, FHedefMayis);
      NewParamForQuery(QueryOfUpdate, FHedefHaziran);
      NewParamForQuery(QueryOfUpdate, FHedefTemmuz);
      NewParamForQuery(QueryOfUpdate, FHedefAgustos);
      NewParamForQuery(QueryOfUpdate, FHedefEylul);
      NewParamForQuery(QueryOfUpdate, FHedefEkim);
      NewParamForQuery(QueryOfUpdate, FHedefKasim);
      NewParamForQuery(QueryOfUpdate, FHedefAralik);
      NewParamForQuery(QueryOfUpdate, FHedefHamOcak);
      NewParamForQuery(QueryOfUpdate, FHedefHamSubat);
      NewParamForQuery(QueryOfUpdate, FHedefHamMart);
      NewParamForQuery(QueryOfUpdate, FHedefHamNisan);
      NewParamForQuery(QueryOfUpdate, FHedefHamMayis);
      NewParamForQuery(QueryOfUpdate, FHedefHamHaziran);
      NewParamForQuery(QueryOfUpdate, FHedefHamTemmuz);
      NewParamForQuery(QueryOfUpdate, FHedefHamAgustos);
      NewParamForQuery(QueryOfUpdate, FHedefHamEylul);
      NewParamForQuery(QueryOfUpdate, FHedefHamEkim);
      NewParamForQuery(QueryOfUpdate, FHedefHamKasim);
      NewParamForQuery(QueryOfUpdate, FHedefHamAralik);
      NewParamForQuery(QueryOfUpdate, FGecenOcak);
      NewParamForQuery(QueryOfUpdate, FGecenSubat);
      NewParamForQuery(QueryOfUpdate, FGecenMart);
      NewParamForQuery(QueryOfUpdate, FGecenNisan);
      NewParamForQuery(QueryOfUpdate, FGecenMayis);
      NewParamForQuery(QueryOfUpdate, FGecenHaziran);
      NewParamForQuery(QueryOfUpdate, FGecenTemmuz);
      NewParamForQuery(QueryOfUpdate, FGecenAgustos);
      NewParamForQuery(QueryOfUpdate, FGecenEylul);
      NewParamForQuery(QueryOfUpdate, FGecenEkim);
      NewParamForQuery(QueryOfUpdate, FGecenKasim);
      NewParamForQuery(QueryOfUpdate, FGecenAralik);
      NewParamForQuery(QueryOfUpdate, FGecenHamOcak);
      NewParamForQuery(QueryOfUpdate, FGecenHamSubat);
      NewParamForQuery(QueryOfUpdate, FGecenHamMart);
      NewParamForQuery(QueryOfUpdate, FGecenHamNisan);
      NewParamForQuery(QueryOfUpdate, FGecenHamMayis);
      NewParamForQuery(QueryOfUpdate, FGecenHamHaziran);
      NewParamForQuery(QueryOfUpdate, FGecenHamTemmuz);
      NewParamForQuery(QueryOfUpdate, FGecenHamAgustos);
      NewParamForQuery(QueryOfUpdate, FGecenHamEylul);
      NewParamForQuery(QueryOfUpdate, FGecenHamEkim);
      NewParamForQuery(QueryOfUpdate, FGecenHamKasim);
      NewParamForQuery(QueryOfUpdate, FGecenHamAralik);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TChBolgeHedef.Clone():TTable;
begin
  Result := TChBolgeHedef.Create(Database);

  Self.Id.Clone(TChBolgeHedef(Result).Id);

  FBolgeID.Clone(TChBolgeHedef(Result).FBolgeID);
  FBolge.Clone(TChBolgeHedef(Result).FBolge);
  FParaBirimi.Clone(TChBolgeHedef(Result).FParaBirimi);
  FHedefOcak.Clone(TChBolgeHedef(Result).FHedefOcak);
  FHedefSubat.Clone(TChBolgeHedef(Result).FHedefSubat);
  FHedefMart.Clone(TChBolgeHedef(Result).FHedefMart);
  FHedefNisan.Clone(TChBolgeHedef(Result).FHedefNisan);
  FHedefMayis.Clone(TChBolgeHedef(Result).FHedefMayis);
  FHedefHaziran.Clone(TChBolgeHedef(Result).FHedefHaziran);
  FHedefTemmuz.Clone(TChBolgeHedef(Result).FHedefTemmuz);
  FHedefAgustos.Clone(TChBolgeHedef(Result).FHedefAgustos);
  FHedefEylul.Clone(TChBolgeHedef(Result).FHedefEylul);
  FHedefEkim.Clone(TChBolgeHedef(Result).FHedefEkim);
  FHedefKasim.Clone(TChBolgeHedef(Result).FHedefKasim);
  FHedefAralik.Clone(TChBolgeHedef(Result).FHedefAralik);
  FHedefHamOcak.Clone(TChBolgeHedef(Result).FHedefHamOcak);
  FHedefHamSubat.Clone(TChBolgeHedef(Result).FHedefHamSubat);
  FHedefHamMart.Clone(TChBolgeHedef(Result).FHedefHamMart);
  FHedefHamNisan.Clone(TChBolgeHedef(Result).FHedefHamNisan);
  FHedefHamMayis.Clone(TChBolgeHedef(Result).FHedefHamMayis);
  FHedefHamHaziran.Clone(TChBolgeHedef(Result).FHedefHamHaziran);
  FHedefHamTemmuz.Clone(TChBolgeHedef(Result).FHedefHamTemmuz);
  FHedefHamAgustos.Clone(TChBolgeHedef(Result).FHedefHamAgustos);
  FHedefHamEylul.Clone(TChBolgeHedef(Result).FHedefHamEylul);
  FHedefHamEkim.Clone(TChBolgeHedef(Result).FHedefHamEkim);
  FHedefHamKasim.Clone(TChBolgeHedef(Result).FHedefHamKasim);
  FHedefHamAralik.Clone(TChBolgeHedef(Result).FHedefHamAralik);
  FGecenOcak.Clone(TChBolgeHedef(Result).FGecenOcak);
  FGecenSubat.Clone(TChBolgeHedef(Result).FGecenSubat);
  FGecenMart.Clone(TChBolgeHedef(Result).FGecenMart);
  FGecenNisan.Clone(TChBolgeHedef(Result).FGecenNisan);
  FGecenMayis.Clone(TChBolgeHedef(Result).FGecenMayis);
  FGecenHaziran.Clone(TChBolgeHedef(Result).FGecenHaziran);
  FGecenTemmuz.Clone(TChBolgeHedef(Result).FGecenTemmuz);
  FGecenAgustos.Clone(TChBolgeHedef(Result).FGecenAgustos);
  FGecenEylul.Clone(TChBolgeHedef(Result).FGecenEylul);
  FGecenEkim.Clone(TChBolgeHedef(Result).FGecenEkim);
  FGecenKasim.Clone(TChBolgeHedef(Result).FGecenKasim);
  FGecenAralik.Clone(TChBolgeHedef(Result).FGecenAralik);
  FGecenHamOcak.Clone(TChBolgeHedef(Result).FGecenHamOcak);
  FGecenHamSubat.Clone(TChBolgeHedef(Result).FGecenHamSubat);
  FGecenHamMart.Clone(TChBolgeHedef(Result).FGecenHamMart);
  FGecenHamNisan.Clone(TChBolgeHedef(Result).FGecenHamNisan);
  FGecenHamMayis.Clone(TChBolgeHedef(Result).FGecenHamMayis);
  FGecenHamHaziran.Clone(TChBolgeHedef(Result).FGecenHamHaziran);
  FGecenHamTemmuz.Clone(TChBolgeHedef(Result).FGecenHamTemmuz);
  FGecenHamAgustos.Clone(TChBolgeHedef(Result).FGecenHamAgustos);
  FGecenHamEylul.Clone(TChBolgeHedef(Result).FGecenHamEylul);
  FGecenHamEkim.Clone(TChBolgeHedef(Result).FGecenHamEkim);
  FGecenHamKasim.Clone(TChBolgeHedef(Result).FGecenHamKasim);
  FGecenHamAralik.Clone(TChBolgeHedef(Result).FGecenHamAralik);
end;

end.
