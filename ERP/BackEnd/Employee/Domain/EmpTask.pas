unit EmpTask;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  [Table('emp_task_translation', 'public')]
  TEmpTaskTranslation = class(TEntityBase)
  private
    FEmpTaskId: Int64;
    FSysLanguageId: Int64;
    FName: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('emp_task_id', [cpPrimaryKey])]
    property EmpTaskId: Int64 read FEmpTaskId write FEmpTaskId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('name')]
    property Name: string read FName write FName;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpTaskTranslation;
  end;

  [Table('emp_task')]
  TEmpTask = class(TEntity)
  private
    FTaskKey: string;
    FTranslations: TObjectList<TEmpTaskTranslation>;

    // View (vw_emp_task) okunabilir alanları
    FTaskName: string;
  public
    [Column('task_key')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property TaskKey: string read FTaskKey write FTaskKey;

    [HasMany('EmpTaskId', 'Id')]
    property Translations: TObjectList<TEmpTaskTranslation> read FTranslations write FTranslations;

    [NotMapped]
    property TaskName: string read FTaskName write FTaskName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpTask;
  end;

implementation

constructor TEmpTask.Create;
begin
  inherited;
  FTranslations := nil;
end;

destructor TEmpTask.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TEmpTask.Clone: TEmpTask;
var
  LTrans: TEmpTaskTranslation;
begin
  Result := TEmpTask.Create;
  Result.Id := Self.Id;
  Result.TaskKey := Self.TaskKey;
  Result.TaskName := Self.TaskName;

  if Assigned(Self.Translations) then
  begin
    Result.Translations := TObjectList<TEmpTaskTranslation>.Create(True);
    for LTrans in Self.Translations do
      Result.Translations.Add(LTrans.Clone);
  end;
end;

constructor TEmpTaskTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TEmpTaskTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TEmpTaskTranslation.Clone: TEmpTaskTranslation;
begin
  Result := TEmpTaskTranslation.Create;
  Result.EmpTaskId := Self.EmpTaskId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.Name := Self.Name;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

end.
