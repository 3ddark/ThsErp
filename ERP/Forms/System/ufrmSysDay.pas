unit ufrmSysDay;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysDay.Service, SysDay;

type
  TfrmSysDay = class(TfrmInputSimpleDB<TSysDay, TSysDayService>)
    pnlContent: TPanel;
    lblday_name: TLabel;
    edtday_name: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysDay.BtnAcceptClick(Sender: TObject);
begin
  Table.DayName := edtday_name.Text;
  inherited;
end;

procedure TfrmSysDay.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysDay.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Day';

  edtday_name.SetFocus;
end;

procedure TfrmSysDay.InitializeInputCase;
begin
  inherited;
  edtday_name.thsInputDataType := itString;
  edtday_name.MaxLength := 16;
end;

procedure TfrmSysDay.RefreshData;
begin
  inherited;
  edtday_name.Text := Table.DayName;
end;

end.
