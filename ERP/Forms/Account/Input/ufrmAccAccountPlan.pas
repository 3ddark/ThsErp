unit ufrmAccAccountPlan;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccAccountPlan.Service, AccAccountPlan;

type
  TfrmAccAccountPlan = class(TfrmInputSimpleDB<TAccAccountPlan, TAccAccountPlanService>)
    pnlContent: TPanel;
    lblcode: TLabel;
    edtcode: TEdit;
    lblname: TLabel;
    edtname: TEdit;
    lbllevel: TLabel;
    edtlevel: TSpinEdit;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmAccAccountPlan.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := edtcode.Text;
  Table.Name := edtname.Text;
  Table.Level := StrToIntDef(edtlevel.Text, 0);
  inherited;
end;

procedure TfrmAccAccountPlan.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmAccAccountPlan.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Account Plan';
  edtcode.SetFocus;
end;

procedure TfrmAccAccountPlan.RefreshData;
begin
  inherited;
  edtcode.Text := Table.Code;
  edtname.Text := Table.Name;
  edtlevel.Text := IntToStr(Table.Level);
end;

end.
