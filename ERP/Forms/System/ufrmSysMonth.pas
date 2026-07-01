unit ufrmSysMonth;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysMonth.Service, SysMonth;

type
  TfrmSysMonth = class(TfrmInputSimpleDB<TSysMonth, TSysMonthService>)
    pnlContent: TPanel;
    lblmonth_name: TLabel;
    edtmonth_name: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysMonth.BtnAcceptClick(Sender: TObject);
begin
  Table.MonthName := edtmonth_name.Text;
  inherited;
end;

procedure TfrmSysMonth.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysMonth.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Month';

  edtmonth_name.SetFocus;
end;

procedure TfrmSysMonth.InitializeInputCase;
begin
  inherited;
  edtmonth_name.thsInputDataType := itString;
  edtmonth_name.MaxLength := 16;
end;

procedure TfrmSysMonth.RefreshData;
begin
  inherited;
  edtmonth_name.Text := Table.MonthName;
end;

end.
