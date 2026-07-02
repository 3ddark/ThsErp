unit ufrmAccHesapPlani;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  ufrmInputSimpleDB,
  SharedFormTypes,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  AccAccountPlan.Service,
  AccAccountPlan;

type
  TfrmAccHesapPlani = class(TfrmInputSimpleDB<TAccAccountPlan, TAaccAccountPlanService>)
    edtcode: TEdit;
    edtname: TEdit;
    edtlevel: TSpinEdit;
    lblcode: TLabel;
    lblname: TLabel;
    lbllevel: TLabel;
  protected
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure HelperProcess(Sender: TObject);
  end;

var
  frmAccHesapPlani: TfrmAccHesapPlani;

implementation

{$R *.dfm}

{ TfrmAccHesapPlani }

procedure TfrmAccHesapPlani.BtnAcceptClick(Sender: TObject);
begin
  Table.Code := edtcode.Text;
  Table.Name := edtname.Text;
  Table.Level := StrToIntDef(edtlevel.Text, 0);
  inherited;
end;

procedure TfrmAccHesapPlani.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmAccHesapPlani.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Hesap Plani';
  edtcode.SetFocus;
end;

procedure TfrmAccHesapPlani.InitializeInputCase;
begin
  edtcode.InputDataType := itString;
  edtname.InputDataType := itString;
  edtlevel.InputDataType := itInteger;

  edtcode.MaxLength := 16;
  edtname.MaxLength := 128;
  edtlevel.MaxLength := 5;
end;

procedure TfrmAccHesapPlani.RefreshData;
begin
  edtcode.Text := Table.Code;
  edtname.Text := Table.Name;
  edtlevel.Text := IntToStr(Table.Level);
end;

procedure TfrmAccHesapPlani.HelperProcess(Sender: TObject);
begin
  // Placeholder for helper form processing logic
end;

end.
