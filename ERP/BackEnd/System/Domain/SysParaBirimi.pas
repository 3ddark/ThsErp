unit SysParaBirimi;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  TSysParaBirimi = class(TEntity)
  private
    FPara: string;
    FSembol: string;
    FAciklama: string;
  public
    property Para: string read FPara write FPara;
    property Sembol: string read FSembol write FSembol;
    property Aciklama: string read FAciklama write FAciklama;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysParaBirimi.Create();
begin
  inherited Create();
end;

destructor TSysParaBirimi.Destroy;
begin
  inherited;
end;

end.
