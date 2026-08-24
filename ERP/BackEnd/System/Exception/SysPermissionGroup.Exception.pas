unit SysPermissionGroup.Exception;

interface

uses
  System.SysUtils, Core.Exception, LocalizationManager;

type
  ESysPermissionGroupException = class(EAppException);

  ESysPermissionGroupExceptionKeyUnique = class(ESysPermissionGroupException)
  protected
    class function GetMessage: string; override;
  end;

implementation


class function ESysPermissionGroupExceptionKeyUnique.GetMessage: string;
begin
  Result := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.KeyUnique, 'İzin Grubu Key değeri zaten atanmış. Tekrar atanamaz.');
end;

end.
