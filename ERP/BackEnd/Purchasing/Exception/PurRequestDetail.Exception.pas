unit PurRequestDetail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurRequestDetailException = class(EAppException);

  EPurRequestDetailExceptionDraftOnly = class(EPurRequestDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurRequestDetailExceptionInventoryUnique = class(EPurRequestDetailException)
  protected
    class function GetMessage: string; override;
  end;

  EPurRequestDetailExceptionLineUnique = class(EPurRequestDetailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurRequestDetailExceptionLineUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.LineUnique, 'This line number is already used on the request.');
end;

class function EPurRequestDetailExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.DraftOnly, 'Only draft requests can be changed.');
end;

class function EPurRequestDetailExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.InventoryUnique, 'This stock card is already on the request.');
end;

end.
