unit SysParaBirimiService;

interface

uses
  SysUtils, Classes, Contnrs, Types,
  Service, UnitOfWork, SysParaBirimiRepository, SysCurrency;

type
  TSysParaBirimiService = class(TCrudService<TSysCurrency>)
  protected
    FRepository: TSysParaBirimiRepository;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TSysParaBirimiService.Create;
begin
  inherited Create;
end;

destructor TSysParaBirimiService.Destroy;
begin
  inherited;
end;

end.

