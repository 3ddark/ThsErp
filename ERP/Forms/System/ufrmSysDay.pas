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
    lblDayName: TLabel;
    edtDayName: TEdit;
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
  Table.DayName := edtDayName.Text;
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

  edtDayName.SetFocus;
end;

procedure TfrmSysDay.InitializeInputCase;
begin
  inherited;
  edtDayName.thsInputDataType := itString;
  edtDayName.MaxLength := 16;
end;

procedure TfrmSysDay.RefreshData;
begin
  inherited;
  edtDayName.Text := Table.DayName;
end;

end.
