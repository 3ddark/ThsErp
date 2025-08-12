unit BaseService;

interface

uses
  SysUtils, Classes, Types, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TBaseService = class
  protected
    constructor Create(AConnection: TFDConnection);
  protected
    function IsAuthorized(): Boolean;
  public
    destructor destroy; virtual;
  end;

implementation

constructor TBaseService.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Service için geçerli bir bağlantı nesnesi sağlanmadı.');
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

