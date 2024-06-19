unit Ths.Orm.Table.StkAmbarlar;

interface

{$I Ths.inc}

uses
  SysUtils, Data.DB, Generics.Collections, Ths.Constants,
  Ths.Orm.Manager, Ths.Orm.ManagerStack, Ths.Orm.Table;

type
  TStkAmbar1 = class(TThsTable)
  private
    FAmbarAdi: TThsField;
    FIsVarsayilanHammadde: TThsField;
    FIsVarsayilanUretim: TThsField;
    FIsVarsayilanSatis: TThsField;
  public
    constructor Create(); override;

    Property AmbarAdi: TThsField read FAmbarAdi write FAmbarAdi;
    Property IsVarsayilanHammadde: TThsField read FIsVarsayilanHammadde write FIsVarsayilanHammadde;
    Property IsVarsayilanUretim: TThsField read FIsVarsayilanUretim write FIsVarsayilanUretim;
    Property IsVarsayilanSatis: TThsField read FIsVarsayilanSatis write FIsVarsayilanSatis;

    class function GetSelectSQL: string; override;
  end;

implementation

constructor TStkAmbar1.Create();
begin
  Self.SchemaName := 'public';
  Self.TableName := 'stk_ambarlar';
  Self.TableSourceCode := MODULE_STK_KAYIT;

  inherited;

  FAmbarAdi := TThsField.Create('ambar_adi', ftString, '', Self, [fpSelect, fpInsert, fpUpdate]);
  FIsVarsayilanHammadde := TThsField.Create('is_varsayilan_hammadde', ftBoolean, False, Self, [fpSelect, fpInsert, fpUpdate]);
  FIsVarsayilanUretim := TThsField.Create('is_varsayilan_uretim', ftBoolean, False, Self, [fpSelect, fpInsert, fpUpdate]);
  FIsVarsayilanSatis := TThsField.Create('is_varsayilan_satis', ftBoolean, False, Self, [fpSelect, fpInsert, fpUpdate]);
end;

class function TStkAmbar1.GetSelectSQL: string;
var
  LTable: TStkAmbar1;
begin
  LTable := TStkAmbar1.Create;
  try
    Result := AppDbContext.PrepareSelectGridQuery(LTable, [
      LTable.FAmbarAdi,
      LTable.FIsVarsayilanHammadde,
      LTable.FIsVarsayilanUretim,
      LTable.FIsVarsayilanSatis
    ]);
  finally
    LTable.Free;
  end;
end;

end.

