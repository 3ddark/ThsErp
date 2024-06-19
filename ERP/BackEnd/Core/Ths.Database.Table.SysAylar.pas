unit Ths.Database.Table.SysAylar;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  Generics.Collections,
  Ths.Orm.Manager,
  Ths.Orm.ManagerStack,
  Ths.Orm.Table;

type
  TSysAy = class(TThsTable)
  private
    FAyAdi: TThsField;
  published
    constructor Create(); override;
  public
    property AyAdi: TThsField read FAyAdi write FAyAdi;
  end;

implementation

uses Ths.Constants;

constructor TSysAy.Create();
begin
  Self.SchemaName := 'public';
  Self.TableName := 'sys_aylar';
  Self.TableSourceCode := MODULE_SISTEM_AYAR;
  inherited;

  FAyAdi := TThsField.Create('ay_adi', ftWideString, '', Self, [fpSelect, fpInsert, fpUpdate]);
end;

end.
