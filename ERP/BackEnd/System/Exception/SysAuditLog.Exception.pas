unit SysAuditLog.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysAuditLogException = class(EAppException);

  ESysAuditLogExceptionReadOnly = class(ESysAuditLogException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysAuditLogExceptionReadOnly.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ReadOnly, 'The audit log is read-only.');
end;

end.
