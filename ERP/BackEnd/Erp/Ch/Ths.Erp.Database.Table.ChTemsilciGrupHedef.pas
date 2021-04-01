unit Ths.Erp.Database.Table.ChTemsilciGrupHedef;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table

  , Ths.Erp.Database.Table.ChTemsilciGrup
  ;

type
  TChTemsilciGrupHedef = class(TTable)
  private
    FTemsilciGrupID: TFieldDB;
    FTemsilciGrup: TFieldDB;
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

    FTemsilciGruplari: TChTemsilciGrup;
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

    Property TemsilciGrupID: TFieldDB read FTemsilciGrupID write FTemsilciGrupID;
    Property TemsilciGrup: TFieldDB read FTemsilciGrup write FTemsilciGrup;
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

constructor TChTemsilciGrupHedef.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'ch_temsilci_grup_hedef';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FTemsilciGruplari := TChTemsilciGrup.Create(Database);

  FTemsilciGrupID := TFieldDB.Create('temsilci_grup_id', ftInteger, 0, Self, '');
  FTemsilciGrup := TFieldDB.Create(FTemsilciGruplari.TemsilciGrup.FieldName, FTemsilciGruplari.TemsilciGrup.DataType, '', Self, '');
  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, '');
  FHedefOcak := TFieldDB.Create('hedef_ocak', ftBCD, 0, Self, '');
  FHedefSubat := TFieldDB.Create('hedef_subat', ftBCD, 0, Self, '');
  FHedefMart := TFieldDB.Create('hedef_mart', ftBCD, 0, Self, '');
  FHedefNisan := TFieldDB.Create('hedef_nisan', ftBCD, 0, Self, '');
  FHedefMayis := TFieldDB.Create('hedef_mayis', ftBCD, 0, Self, '');
  FHedefHaziran := TFieldDB.Create('hedef_haziran', ftBCD, 0, Self, '');
  FHedefTemmuz := TFieldDB.Create('hedef_temmuz', ftBCD, 0, Self, '');
  FHedefAgustos := TFieldDB.Create('hedef_agustos', ftBCD, 0, Self, '');
  FHedefEylul := TFieldDB.Create('hedef_eylul', ftBCD, 0, Self, '');
  FHedefEkim := TFieldDB.Create('hedef_ekim', ftBCD, 0, Self, '');
  FHedefKasim := TFieldDB.Create('hedef_kasim', ftBCD, 0, Self, '');
  FHedefAralik := TFieldDB.Create('hedef_aralik', ftBCD, 0, Self, '');
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

destructor TChTemsilciGrupHedef.Destroy;
begin
  FTemsilciGruplari.Free;
  inherited;
end;

procedure TChTemsilciGrupHedef.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTemsilciGrupID.FieldName,
        addLangField(FTemsilciGrup.FieldName),
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
        addLeftJoin(FTemsilciGrup.FieldName, FTemsilciGrupID.FieldName, FTemsilciGruplari.TableName),
        'WHERE 1=1 ' + pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTemsilciGrupID, 'Temsilci Grup ID', QueryOfDS);
      setFieldTitle(FTemsilciGrup, 'Temsilci Grup', QueryOfDS);
      setFieldTitle(FParaBirimi, 'Para Birimi', QueryOfDS);
      setFieldTitle(FHedefOcak, 'Hedef Ocak', QueryOfDS);
      setFieldTitle(FHedefSubat, 'Hedef �ubat', QueryOfDS);
      setFieldTitle(FHedefMart, 'Hedef Mart', QueryOfDS);
      setFieldTitle(FHedefNisan, 'Hedef Nisan', QueryOfDS);
      setFieldTitle(FHedefMayis, 'Hedef May�s', QueryOfDS);
      setFieldTitle(FHedefHaziran, 'Hedef Haziran', QueryOfDS);
      setFieldTitle(FHedefTemmuz, 'Hedef Temmuz', QueryOfDS);
      setFieldTitle(FHedefAgustos, 'Hedef A�ustos', QueryOfDS);
      setFieldTitle(FHedefEylul, 'Hedef Eyl�l', QueryOfDS);
      setFieldTitle(FHedefEkim, 'Hedef Ekim', QueryOfDS);
      setFieldTitle(FHedefKasim, 'Hedef Kas�m', QueryOfDS);
      setFieldTitle(FHedefAralik, 'Hedef Aral�k', QueryOfDS);
      setFieldTitle(FHedefHamOcak, 'Hedef Mam�l/Hammadde Ocak', QueryOfDS);
      setFieldTitle(FHedefHamSubat, 'Hedef Mam�l/Hammadde �ubat', QueryOfDS);
      setFieldTitle(FHedefHamMart, 'Hedef Mam�l/Hammadde Mart', QueryOfDS);
      setFieldTitle(FHedefHamNisan, 'Hedef Mam�l/Hammadde Nisan', QueryOfDS);
      setFieldTitle(FHedefHamMayis, 'Hedef Mam�l/Hammadde May�s', QueryOfDS);
      setFieldTitle(FHedefHamHaziran, 'Hedef Mam�l/Hammadde Haziran', QueryOfDS);
      setFieldTitle(FHedefHamTemmuz, 'Hedef Mam�l/Hammadde Temmuz', QueryOfDS);
      setFieldTitle(FHedefHamAgustos, 'Hedef Mam�l/Hammadde A�ustos', QueryOfDS);
      setFieldTitle(FHedefHamEylul, 'Hedef Mam�l/Hammadde Eyl�l', QueryOfDS);
      setFieldTitle(FHedefHamEkim, 'Hedef Mam�l/Hammadde Ekim', QueryOfDS);
      setFieldTitle(FHedefHamKasim, 'Hedef Mam�l/Hammadde Kas�m', QueryOfDS);
      setFieldTitle(FHedefHamAralik, 'Hedef Mam�l/Hammadde Aral�k', QueryOfDS);
      setFieldTitle(FGecenOcak, 'Ge�mi� Ocak', QueryOfDS);
      setFieldTitle(FGecenSubat, 'Ge�mi� �ubat', QueryOfDS);
      setFieldTitle(FGecenMart, 'Ge�mi� Mart', QueryOfDS);
      setFieldTitle(FGecenNisan, 'Ge�mi� Nisan', QueryOfDS);
      setFieldTitle(FGecenMayis, 'Ge�mi� May�s', QueryOfDS);
      setFieldTitle(FGecenHaziran, 'Ge�mi� Haziran', QueryOfDS);
      setFieldTitle(FGecenTemmuz, 'Ge�mi� Temmuz', QueryOfDS);
      setFieldTitle(FGecenAgustos, 'Ge�mi� A�ustos', QueryOfDS);
      setFieldTitle(FGecenEylul, 'Ge�mi� Eyl�l', QueryOfDS);
      setFieldTitle(FGecenEkim, 'Ge�mi� Ekim', QueryOfDS);
      setFieldTitle(FGecenKasim, 'Ge�mi� Kas�m', QueryOfDS);
      setFieldTitle(FGecenAralik, 'Ge�mi� Aral�k', QueryOfDS);
      setFieldTitle(FGecenHamOcak, 'Ge�mi� Mam�l/Hammadde Ocak', QueryOfDS);
      setFieldTitle(FGecenHamSubat, 'Ge�mi� Mam�l/Hammadde �ubat', QueryOfDS);
      setFieldTitle(FGecenHamMart, 'Ge�mi� Mam�l/Hammadde Mart', QueryOfDS);
      setFieldTitle(FGecenHamNisan, 'Ge�mi� Mam�l/Hammadde Nisan', QueryOfDS);
      setFieldTitle(FGecenHamMayis, 'Ge�mi� Mam�l/Hammadde May�s', QueryOfDS);
      setFieldTitle(FGecenHamHaziran, 'Ge�mi� Mam�l/Hammadde Haziran', QueryOfDS);
      setFieldTitle(FGecenHamTemmuz, 'Ge�mi� Mam�l/Hammadde Temmuz', QueryOfDS);
      setFieldTitle(FGecenHamAgustos, 'Ge�mi� Mam�l/Hammadde A�ustos', QueryOfDS);
      setFieldTitle(FGecenHamEylul, 'Ge�mi� Mam�l/Hammadde Eyl�l', QueryOfDS);
      setFieldTitle(FGecenHamEkim, 'Ge�mi� Mam�l/Hammadde Ekim', QueryOfDS);
      setFieldTitle(FGecenHamKasim, 'Ge�mi� Mam�l/Hammadde Kas�m', QueryOfDS);
      setFieldTitle(FGecenHamAralik, 'Ge�mi� Mam�l/Hammadde Aral�k', QueryOfDS);
    end;
  end;
end;

procedure TChTemsilciGrupHedef.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FTemsilciGrupID.FieldName,
        addLangField(FTemsilciGrup.FieldName),
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
        addLeftJoin(FTemsilciGrup.FieldName, FTemsilciGrupID.FieldName, FTemsilciGruplari.TableName),
        'WHERE 1=1 ' + pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FTemsilciGrupID, QueryOfList);
        setFieldValue(FTemsilciGrup, QueryOfList);
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

procedure TChTemsilciGrupHedef.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTemsilciGrupID.FieldName,
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

      NewParamForQuery(QueryOfInsert, FTemsilciGrupID);
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

procedure TChTemsilciGrupHedef.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTemsilciGrupID.FieldName,
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

      NewParamForQuery(QueryOfUpdate, FTemsilciGrupID);
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

function TChTemsilciGrupHedef.Clone():TTable;
begin
  Result := TChTemsilciGrupHedef.Create(Database);

  Self.Id.Clone(TChTemsilciGrupHedef(Result).Id);

  FTemsilciGrupID.Clone(TChTemsilciGrupHedef(Result).FTemsilciGrupID);
  FTemsilciGrup.Clone(TChTemsilciGrupHedef(Result).FTemsilciGrup);
  FParaBirimi.Clone(TChTemsilciGrupHedef(Result).FParaBirimi);
  FHedefOcak.Clone(TChTemsilciGrupHedef(Result).FHedefOcak);
  FHedefSubat.Clone(TChTemsilciGrupHedef(Result).FHedefSubat);
  FHedefMart.Clone(TChTemsilciGrupHedef(Result).FHedefMart);
  FHedefNisan.Clone(TChTemsilciGrupHedef(Result).FHedefNisan);
  FHedefMayis.Clone(TChTemsilciGrupHedef(Result).FHedefMayis);
  FHedefHaziran.Clone(TChTemsilciGrupHedef(Result).FHedefHaziran);
  FHedefTemmuz.Clone(TChTemsilciGrupHedef(Result).FHedefTemmuz);
  FHedefAgustos.Clone(TChTemsilciGrupHedef(Result).FHedefAgustos);
  FHedefEylul.Clone(TChTemsilciGrupHedef(Result).FHedefEylul);
  FHedefEkim.Clone(TChTemsilciGrupHedef(Result).FHedefEkim);
  FHedefKasim.Clone(TChTemsilciGrupHedef(Result).FHedefKasim);
  FHedefAralik.Clone(TChTemsilciGrupHedef(Result).FHedefAralik);
  FHedefHamOcak.Clone(TChTemsilciGrupHedef(Result).FHedefHamOcak);
  FHedefHamSubat.Clone(TChTemsilciGrupHedef(Result).FHedefHamSubat);
  FHedefHamMart.Clone(TChTemsilciGrupHedef(Result).FHedefHamMart);
  FHedefHamNisan.Clone(TChTemsilciGrupHedef(Result).FHedefHamNisan);
  FHedefHamMayis.Clone(TChTemsilciGrupHedef(Result).FHedefHamMayis);
  FHedefHamHaziran.Clone(TChTemsilciGrupHedef(Result).FHedefHamHaziran);
  FHedefHamTemmuz.Clone(TChTemsilciGrupHedef(Result).FHedefHamTemmuz);
  FHedefHamAgustos.Clone(TChTemsilciGrupHedef(Result).FHedefHamAgustos);
  FHedefHamEylul.Clone(TChTemsilciGrupHedef(Result).FHedefHamEylul);
  FHedefHamEkim.Clone(TChTemsilciGrupHedef(Result).FHedefHamEkim);
  FHedefHamKasim.Clone(TChTemsilciGrupHedef(Result).FHedefHamKasim);
  FHedefHamAralik.Clone(TChTemsilciGrupHedef(Result).FHedefHamAralik);
  FGecenOcak.Clone(TChTemsilciGrupHedef(Result).FGecenOcak);
  FGecenSubat.Clone(TChTemsilciGrupHedef(Result).FGecenSubat);
  FGecenMart.Clone(TChTemsilciGrupHedef(Result).FGecenMart);
  FGecenNisan.Clone(TChTemsilciGrupHedef(Result).FGecenNisan);
  FGecenMayis.Clone(TChTemsilciGrupHedef(Result).FGecenMayis);
  FGecenHaziran.Clone(TChTemsilciGrupHedef(Result).FGecenHaziran);
  FGecenTemmuz.Clone(TChTemsilciGrupHedef(Result).FGecenTemmuz);
  FGecenAgustos.Clone(TChTemsilciGrupHedef(Result).FGecenAgustos);
  FGecenEylul.Clone(TChTemsilciGrupHedef(Result).FGecenEylul);
  FGecenEkim.Clone(TChTemsilciGrupHedef(Result).FGecenEkim);
  FGecenKasim.Clone(TChTemsilciGrupHedef(Result).FGecenKasim);
  FGecenAralik.Clone(TChTemsilciGrupHedef(Result).FGecenAralik);
  FGecenHamOcak.Clone(TChTemsilciGrupHedef(Result).FGecenHamOcak);
  FGecenHamSubat.Clone(TChTemsilciGrupHedef(Result).FGecenHamSubat);
  FGecenHamMart.Clone(TChTemsilciGrupHedef(Result).FGecenHamMart);
  FGecenHamNisan.Clone(TChTemsilciGrupHedef(Result).FGecenHamNisan);
  FGecenHamMayis.Clone(TChTemsilciGrupHedef(Result).FGecenHamMayis);
  FGecenHamHaziran.Clone(TChTemsilciGrupHedef(Result).FGecenHamHaziran);
  FGecenHamTemmuz.Clone(TChTemsilciGrupHedef(Result).FGecenHamTemmuz);
  FGecenHamAgustos.Clone(TChTemsilciGrupHedef(Result).FGecenHamAgustos);
  FGecenHamEylul.Clone(TChTemsilciGrupHedef(Result).FGecenHamEylul);
  FGecenHamEkim.Clone(TChTemsilciGrupHedef(Result).FGecenHamEkim);
  FGecenHamKasim.Clone(TChTemsilciGrupHedef(Result).FGecenHamKasim);
  FGecenHamAralik.Clone(TChTemsilciGrupHedef(Result).FGecenHamAralik);
end;

end.
