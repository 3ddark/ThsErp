unit SetPrsTask;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_prs_tasks')]
  TSetPrsTask = class(TEntity)
  private
    FTaskName: string;
  public
    [Column('task_name')]
    Property TaskName: string read FTaskName write FTaskName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetPrsTask.Create();
begin
  inherited;
end;

destructor TSetPrsTask.Destroy;
begin

  inherited;
end;

end.
