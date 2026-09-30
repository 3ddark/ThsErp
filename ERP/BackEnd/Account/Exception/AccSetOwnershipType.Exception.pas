unit AccSetOwnershipType.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAccSetOwnershipTypeException = class(EAppException);

  EAccSetOwnershipTypeExceptionOwnershipTypeKeyUnique = class(EAccSetOwnershipTypeException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAccSetOwnershipTypeExceptionOwnershipTypeKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.OwnershipTypeKeyUnique, 'This ownership type key already exists.');
end;

end.
