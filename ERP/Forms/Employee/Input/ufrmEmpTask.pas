unit ufrmEmpTask;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpTask.Service, EmpTask, LocalizationManager;

type
  TfrmEmpTask = class(TfrmInputSimpleDB<TEmpTask, TEmpTaskService>)
    pnlContent: TPanel;
    lblTaskName: TLabel;
    edtTaskName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmEmpTask.BtnAcceptClick(Sender: TObject);
begin
  Table.TaskName := edtTaskName.Text;
  inherited;
end;

procedure TfrmEmpTask.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmEmpTask.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtTaskName.SetFocus;
end;

procedure TfrmEmpTask.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_task.title_singular', 'Görev');
  lblTaskName.Caption := TLocalizationManager.Translate('emp_task.lbl_task_name', 'Görev Adı');
end;

procedure TfrmEmpTask.InitializeInputCase;
begin
  inherited;
  edtTaskName.thsInputDataType := itString;
  edtTaskName.MaxLength := 32;
end;

procedure TfrmEmpTask.RefreshData;
begin
  inherited;
  edtTaskName.Text := Table.TaskName;
end;

end.
