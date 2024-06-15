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
  ManagerApp: TEntityManager;

implementation

{ TManagerStack }

destructor TManagerStack.Destroy;
begin
  ManagerApp.Free;
  inherited;
end;

class procedure TManagerStack.prepareManager(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer);
begin
  ManagerApp := TEntityManager.Create(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath, APort);
end;

initialization

finalization
  ManagerApp.Free;

end.
