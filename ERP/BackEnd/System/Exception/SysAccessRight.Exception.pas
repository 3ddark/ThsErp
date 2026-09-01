unit SysAccessRight.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EAuthorizationException = class(EAppException);

  EAuthorizationExceptionRead = class(EAuthorizationException)
  protected
    class function GetMessage: string; override;
  end;

  EAuthorizationExceptionAdd = class(EAuthorizationException)
  protected
    class function GetMessage: string; override;
  end;

  EAuthorizationExceptionUpdate = class(EAuthorizationException)
  protected
    class function GetMessage: string; override;
  end;

  EAuthorizationExceptionDelete = class(EAuthorizationException)
  protected
    class function GetMessage: string; override;
  end;

  EAuthorizationExceptionSpecial = class(EAuthorizationException)
  protected
    class function GetMessage: string; override;
  end;

  EAuthorizationExceptionPermissionUserUnique = class(EAuthorizationException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EAuthorizationExceptionRead.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgNoAccessRightToRead, 'You do not have permission to read the recordings!');
end;

class function EAuthorizationExceptionAdd.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgNoAccessRightToAdd, 'You do not have the right to add new records.');
end;

class function EAuthorizationExceptionUpdate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgNoAccessRightToUpdate, 'No right to update registration.');
end;

class function EAuthorizationExceptionDelete.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgNoAccessRightToDelete, 'No right to delete records');
end;

class function EAuthorizationExceptionSpecial.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgNoAccessRightToSpecial, 'No special treatment rights');
end;

class function EAuthorizationExceptionPermissionUserUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.MsgPermissionUserUnique, 'Access rights have already been assigned to the user. They cannot be reassigned.');
end;

end.
