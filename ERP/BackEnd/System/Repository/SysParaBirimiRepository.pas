unit SysParaBirimiRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCurrency;

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

