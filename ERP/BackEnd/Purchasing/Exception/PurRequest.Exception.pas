unit PurRequest.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  EPurRequestException = class(EAppException);

  EPurRequestExceptionNoUnique = class(EPurRequestException)
  protected
    class function GetMessage: string; override;
  end;

  EPurRequestExceptionDraftOnly = class(EPurRequestException)
  protected
    class function GetMessage: string; override;
  end;

  EPurRequestExceptionNoLines = class(EPurRequestException)
  protected
    class function GetMessage: string; override;
  end;

  EPurRequestExceptionHasOrders = class(EPurRequestException)
  protected
    class function GetMessage: string; override;
  end;

  EPurRequestExceptionRequiredDate = class(EPurRequestException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function EPurRequestExceptionNoUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequest.NoUnique, 'This request number already exists.');
end;

class function EPurRequestExceptionDraftOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequest.DraftOnly, 'Only draft requests can be changed.');
end;

class function EPurRequestExceptionNoLines.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequest.NoLines, 'The request has no lines.');
end;

class function EPurRequestExceptionHasOrders.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequest.HasOrders, 'Lines of this request are already on orders.');
end;

class function EPurRequestExceptionRequiredDate.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TPurRequest.RequiredDate, 'Required date cannot be earlier than the request date.');
end;

end.
