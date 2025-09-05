unit SysParaBirimi;

interface

uses
  SysUtils, Classes, Types, BaseEntity;

type
  TSysParaBirimi = class(TEntity)
  private
    FPara: TEntityField<string>;
    FSembol: TEntityField<string>;
    FAciklama: TEntityField<string>;
  public
    property Para: TEntityField<string> read FPara write FPara;
    property Sembol: TEntityField<string> read FSembol write FSembol;
    property Aciklama: TEntityField<string> read FAciklama write FAciklama;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysParaBirimi.Create();
begin
  inherited Create();
  FPara := TEntityField<string>.Create(Self, 'para');
  FSembol := TEntityField<string>.Create(Self, 'sembol');
  FAciklama := TEntityField<string>.Create(Self, 'aciklama');
end;

destructor TSysParaBirimi.Destroy;
begin
  FPara.Free;
  FSembol.Free;
  FAciklama.Free;
  inherited;
end;

end.
