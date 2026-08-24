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
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.NoAccessRightToRead, 'Kayıt Okuma hakkı yok');
end;

class function EAuthorizationExceptionAdd.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.NoAccessRightToAdd, 'Yeni Kayıt Ekleme hakkı yok');
end;

class function EAuthorizationExceptionUpdate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.NoAccessRightToUpdate, 'Kayıt Güncelleme hakkı yok');
end;

class function EAuthorizationExceptionDelete.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.NoAccessRightToDelete, 'Kayıt Silme hakkı yok');
end;

class function EAuthorizationExceptionSpecial.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.NoAccessRightToSpecial, 'Özel İşlem hakkı yok');
end;

class function EAuthorizationExceptionPermissionUserUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.PermissionUserUnique, 'Permission kullanıcıya zaten atanmış. Tekrar atanamaz.');
end;

end.
