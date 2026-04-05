unit SysParaBirimiRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.Param, Repository, SysCurrency;

type
  TSysParaBirimiRepository = class(TRepository<TSysCurrency>)
  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
  end;

implementation

constructor TSysParaBirimiRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

destructor TSysParaBirimiRepository.Destroy;
begin
  //
  inherited;
end;

end.

