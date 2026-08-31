unit SysPermission.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysPermissionException = class(EAppException);

  ESysPermissionExceptionKeyUnique = class(ESysPermissionException)
  protected
    class function GetMessage: string; override;
  end;

implementation

class function ESysPermissionExceptionKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysPermission.KeyUnique, 'İzin Key değeri zaten atanmış. Tekrar atanamaz.');
end;

end.
