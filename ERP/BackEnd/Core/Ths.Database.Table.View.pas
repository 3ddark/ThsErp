unit Ths.Database.Table.View;

interface

{$I Ths.inc}

uses
  Forms, SysUtils, Classes, Dialogs, System.Rtti, Data.DB, Ths.Database.Table;

type
  TView = class(TTable)
  public
    procedure Listen(); override;
    procedure Unlisten(); override;
    procedure Notify(); override;

    procedure DoInsert(APermissionControl: Boolean = True); override;
    procedure DoUpdate(APermissionControl: Boolean = True); override;
    procedure Delete(APermissionControl: Boolean = True); override;

    function LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionControl: Boolean): Boolean; override;
    function LogicalInsert(AWithBegin, AWithCommit, APermissionControl: Boolean): Boolean; override;
    function LogicalUpdate(AWithCommit, APermissionControl: Boolean): Boolean; override;
    function LogicalDelete(AWithCommit, APermissionControl: Boolean): Boolean; override;
  end;

implementation

uses
  Ths.Globals;

procedure TView.Listen;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

procedure TView.Notify;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

procedure TView.Unlisten;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

function TView.LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionControl: Boolean): Boolean;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

function TView.LogicalInsert(AWithBegin, AWithCommit, APermissionControl: Boolean): Boolean;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

function TView.LogicalUpdate(AWithCommit, APermissionControl: Boolean): Boolean;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

function TView.LogicalDelete(AWithCommit, APermissionControl: Boolean): Boolean;
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

procedure TView.DoInsert(APermissionControl: Boolean = True);
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

procedure TView.DoUpdate(APermissionControl: Boolean = True);
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

procedure TView.Delete(APermissionControl: Boolean);
begin
  raise Exception.Create('Desteklenmeyen işlem' + AddLBs + self.ClassName);
end;

end.
