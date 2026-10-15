unit SysMenu.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysMenuException = class(EAppException);

  // kod MMGGSS (100000-999999)
  ESysMenuExceptionCodeRange = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  // klasör (MM0000 / MMGG00) action / yetki almaz; ekran action ister
  ESysMenuExceptionFolderRule = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  // üst klasör (MM0000 / MMGG00) önce eklenmeli
  ESysMenuExceptionParentMissing = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  ESysMenuExceptionCodeUnique = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  ESysMenuExceptionKeyUnique = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  ESysMenuExceptionActionUnique = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  // kod / anahtar / action eklendikten sonra değişmez (kılavuz ve destek kodlara başvurur)
  ESysMenuExceptionImmutable = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

  // silinen kod başka ekrana verilebilirdi: silme yok, pasif yapılır
  ESysMenuExceptionNoDelete = class(ESysMenuException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysMenuExceptionCodeRange.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.MsgCodeRange,
    'The menu code must be a 6-digit number (MMGGSS: module, group, screen).');
end;

class function ESysMenuExceptionFolderRule.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.MsgFolderRule,
    'Folder codes (ending with 00) cannot have an action or permission; screen codes need an action.');
end;

class function ESysMenuExceptionParentMissing.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.MsgParentMissing,
    'The parent folder of this code does not exist. Add the module / group row first.');
end;

class function ESysMenuExceptionCodeUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.CodeUnique, 'This menu code is already in use.');
end;

class function ESysMenuExceptionKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.KeyUnique, 'This menu key is already in use.');
end;

class function ESysMenuExceptionActionUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.ActionUnique, 'This action already has a menu row.');
end;

class function ESysMenuExceptionImmutable.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.MsgImmutable,
    'Menu code, key and action cannot be changed after the row is created.');
end;

class function ESysMenuExceptionNoDelete.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysMenu.MsgNoDelete,
    'Menu rows cannot be deleted (their codes are permanent). Make the row passive instead.');
end;

end.
