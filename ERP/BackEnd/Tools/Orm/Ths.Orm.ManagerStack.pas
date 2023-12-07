unit Ths.Orm.ManagerStack;

interface

uses
  Ths.Orm.Manager;

type
  TManagerStack = class
  public
    class procedure prepareManager(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer);
    destructor Destroy; override;
  end;

var
  AppContext: TEntityManager;

implementation

{ TManagerStack }

destructor TManagerStack.Destroy;
begin
  AppContext.Free;
  inherited;
end;

class procedure TManagerStack.prepareManager(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer);
begin
  AppContext := TEntityManager.Create(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath, APort);
end;

initialization

finalization
  AppContext.Free;

end.
