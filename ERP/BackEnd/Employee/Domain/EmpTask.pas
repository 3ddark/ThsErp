unit EmpTask;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_task')]
  TEmpTask = class(TEntity)
  private
    FTaskName: string;
  public
    [Column('task_name')]
    Property TaskName: string read FTaskName write FTaskName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpTask;
  end;

implementation

constructor TEmpTask.Create();
begin
  inherited;
end;

destructor TEmpTask.Destroy;
begin

  inherited;
end;

function TEmpTask.Clone: TEmpTask;
begin
  Result := TEmpTask.Create;
  Result.TaskName := Self.TaskName;
end;

end.