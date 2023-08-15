unit Ths.Orm.Table.SysParaBirimleri;

interface

{$I Ths.inc}

uses Data.DB, Ths.Orm.Table, Ths.Constants;

type
  TSysParaBirimi = class(TThsTable)
  private
    FPara: TThsField;
    FSembol: TThsField;
    FAciklama: TThsField;
  published
    constructor Create(AName: string); reintroduce; overload;
  public
    property Para: TThsField read FPara write FPara;
    property Sembol: TThsField read FSembol write FSembol;
    property Aciklama: TThsField read FAciklama write FAciklama;

    function Clone: TSysParaBirimi; reintroduce; overload;
  end;

implementation

constructor TSysParaBirimi.Create(AName: string);
begin
  SchemaName := 'public';
  TableName := 'sys_para_birimleri';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create;

  FPara := TThsField.Create('para', ftString, '', Self, [fpSelect, fpInsert, fpUpdate]);
  FSembol := TThsField.Create('sembol', ftString, '', Self, [fpSelect, fpInsert, fpUpdate]);
  FAciklama := TThsField.Create('aciklama', ftString, '', Self, [fpSelect, fpInsert, fpUpdate]);
end;

function TSysParaBirimi.Clone: TSysParaBirimi;
begin
  Result := TSysParaBirimi.Create;
  Result.CloneData(Self);
end;

end.
