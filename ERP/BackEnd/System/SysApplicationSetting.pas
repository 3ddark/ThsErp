unit SysApplicationSetting;

interface

uses SysUtils, Classes, Types, BaseEntity;

type
  [TableName('sys_application_settings')]
  TSysApplicationSetting = class(TEntity)
  private
    FCompanyTitle: TEntityField<string>;
  public
    property CompanyTitle: TEntityField<string> read FCompanyTitle write FCompanyTitle;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysApplicationSetting.Create();
begin
  inherited;
  FCompanyTitle := TEntityField<string>.Create(Self, 'company_title');
end;

destructor TSysApplicationSetting.Destroy;
begin
  inherited;
end;

end.
