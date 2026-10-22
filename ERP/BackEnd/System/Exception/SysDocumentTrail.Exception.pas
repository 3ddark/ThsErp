unit SysDocumentTrail.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysDocumentTrailException = class(EAppException);

  ESysDocumentTrailExceptionReadOnly = class(ESysDocumentTrailException)
  protected
    class function GetMessage: string; override;
  end;

  ESysDocumentTrailExceptionNoSource = class(ESysDocumentTrailException)
  protected
    class function GetMessage: string; override;
  end;

  ESysDocumentTrailExceptionUnknownDocument = class(ESysDocumentTrailException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysDocumentTrailExceptionReadOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.ReadOnly, 'The document trail is read-only.');
end;

class function ESysDocumentTrailExceptionNoSource.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.MsgNoSource, 'The document trail is opened from a document.');
end;

class function ESysDocumentTrailExceptionUnknownDocument.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysDocumentTrail.MsgUnknownDocument, 'This document type has no trail.');
end;

end.
