unit BaseService;

interface

uses
  SysUtils, Classes, Types, ZConnection;

type
  TBaseService = class
  protected
    constructor Create(AConnection: TZConnection);
  protected
    function IsAuthorized(): Boolean;
  public
    destructor destroy; override;
  end;

implementation

constructor TBaseService.Create(AConnection: TZConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Service için geçerli bir baðlantý nesnesi saðlanmadý.');
end;

destructor TBaseService.destroy;
begin
  inherited;
end;

function TBaseService.IsAuthorized: Boolean;
begin
  Result := True;
end;

end.

