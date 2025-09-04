unit BaseService;

interface

uses
  SysUtils, Classes, Types, FireDAC.Comp.Client,
  EntityMetaProvider, BaseRepository;

const
  KeyStkCinsAile = 'StkCinsAile';

type
  TBaseService = class
  protected
    FMetas: TArray<TFieldMeta>;
    FRepository: TBaseRepository;

    constructor Create(AConnection: TFDConnection);
  private
  protected
    function IsAuthorized(): Boolean;
  public
    function GetConnection: TFDConnection; virtual; abstract;
  end;

implementation

constructor TBaseService.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Service için geçerli bir bağlantı nesnesi sağlanmadı.');
end;

function TBaseService.IsAuthorized: Boolean;
begin
  Result := True;
end;

end.

