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

implementation

class function EPurRequestDetailExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.DraftOnly, 'Only draft requests can be changed.');
end;

class function EPurRequestDetailExceptionInventoryUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.InventoryUnique, 'This stock card is already on the request.');
end;

end.
