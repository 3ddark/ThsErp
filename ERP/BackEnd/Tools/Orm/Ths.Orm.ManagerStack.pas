unit Ths.Orm.ManagerStack;

interface

uses
  Ths.Orm.Manager, System.Generics.Collections;

type
  TManagerStack = class
  public
    class procedure prepareManager(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer);
    destructor Destroy; override;
  end;

var
  DbContext: TObjectList<TEntityManager>;
  AppDbContext: TEntityManager;

implementation

{ TManagerStack }

destructor TManagerStack.Destroy;
begin
  AppDbContext.Free;
  inherited;
end;

class procedure TManagerStack.prepareManager(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath: string; APort: Integer);
begin
  if DbContext = nil then
    DbContext := TObjectList<TEntityManager>.Create;

  DbContext.Add(TEntityManager.Create(AHostName, ADatabase, AUserName, AUserPass, ALibraryPath, APort));
  AppDbContext := DbContext.Items[0];
end;

initialization

finalization
  DbContext.Free;

end.
