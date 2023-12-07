unit Ths.Orm.Table.StkAmbarlar;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  Generics.Collections,
  Ths.Orm.Manager,
  Ths.Orm.ManagerStack,
  Ths.Orm.Table;

type
  TStkAmbar = class(TThsTable)
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

//    function SelectToDS(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkAmbar.Create();
begin
  Self.SchemaName := 'public';
  Self.TableName := 'stk_ambarlar';
  Self.TableSourceCode := '1000';

  inherited;

  FAmbarAdi := TThsField.Create('ambar_adi', ftString, '', Self, [fpSelect, fpInsert, fpUpdate]);
  FIsVarsayilanHammadde := TThsField.Create('is_varsayilan_hammadde', ftBoolean, False, Self, [fpSelect, fpInsert, fpUpdate]);
  FIsVarsayilanUretim := TThsField.Create('is_varsayilan_uretim', ftBoolean, False, Self, [fpSelect, fpInsert, fpUpdate]);
  FIsVarsayilanSatis := TThsField.Create('is_varsayilan_satis', ftBoolean, False, Self, [fpSelect, fpInsert, fpUpdate]);
end;

//function TStkAmbar.SelectToDS(AFilter: string; APermissionControl, AAllColumn, AHelper: Boolean): string;
//begin
//  if not ManagerApp.IsAuthorized(Self.TableSourceCode, TPermissionTypes.prtRead, APermissionControl) then
//    Exit;
//{
//  with QryOfDS do
//  begin
//    Close;
//    Database.GetSQLSelectCmd(QryOfDS, TableName, [
//      Id.QryName,
//      FAmbarAdi.QryName,
//      FIsVarsayilanHammadde.QryName,
//      FIsVarsayilanUretim.QryName,
//      FIsVarsayilanSatis.QryName
//    ], [
//      ' WHERE 1=1 ', AFilter
//    ], AAllColumn, AHelper);
//    Open;
//  end;
//}
//end;

end.



