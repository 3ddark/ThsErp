unit Ths.Orm.Table.SysOndalikHaneler;

interface

{$I Ths.inc}

uses Data.DB, Ths.Orm.Table, Ths.Constants;

type
  TSysOndalikHane = class(TThsTable)
  private
    FMiktar: TThsField;
    FFiyat: TThsField;
    FTutar: TThsField;
    FStokMiktar: TThsField;
    FDovizKuru: TThsField;
  published
    constructor Create; override;
  public
    property Miktar: TThsField read FMiktar write FMiktar;
    property Fiyat: TThsField read FFiyat write FFiyat;
    property Tutar: TThsField read FTutar write FTutar;
    property StokMiktar: TThsField read FStokMiktar write FStokMiktar;
    property DovizKuru: TThsField read FDovizKuru write FDovizKuru;

    function Clone: TSysOndalikHane; reintroduce; overload;
  end;

implementation

constructor TSysOndalikHane.Create;
begin
  SchemaName := 'public';
  TableName := 'sys_ondalik_haneler';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited;

  FMiktar := TThsField.Create('miktar', ftSmallint, 2, Self, [fpSelect, fpInsert, fpUpdate]);
  FFiyat := TThsField.Create('fiyat', ftSmallint, 2, Self, [fpSelect, fpInsert, fpUpdate]);
  FTutar := TThsField.Create('tutar', ftSmallint, 2, Self, [fpSelect, fpInsert, fpUpdate]);
  FStokMiktar := TThsField.Create('stok_miktar', ftSmallint, 2, Self, [fpSelect, fpInsert, fpUpdate]);
  FDovizKuru := TThsField.Create('doviz_kuru', ftSmallint, 4, Self, [fpSelect, fpInsert, fpUpdate]);
end;

function TSysOndalikHane.Clone: TSysOndalikHane;
begin
  Result := TSysOndalikHane.Create;
  Result.CloneData(Self);
end;

end.
