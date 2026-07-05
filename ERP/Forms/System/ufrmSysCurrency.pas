unit ufrmSysCurrency;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCurrency.Service, SysCurrency;

type
  TfrmSysCurrency = class(TfrmInputSimpleDB<TSysCurrency, TSysCurrencyService>)
    pnlContent: TPanel;
    lblCurrency: TLabel;
    lblSymbol: TLabel;
    lblDescription: TLabel;
    edtCurrency: TEdit;
    edtSymbol: TEdit;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCurrency.BtnAcceptClick(Sender: TObject);
begin
  Table.Currency := edtCurrency.Text;
  Table.Symbol := edtSymbol.Text;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSysCurrency.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysCurrency.InitializeInputCase;
begin
  inherited;
  edtCurrency.thsInputDataType := itString;
  edtSymbol.thsInputDataType := itString;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSysCurrency.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Currency';

  edtCurrency.SetFocus;
end;

procedure TfrmSysCurrency.RefreshData;
begin
  inherited;
  edtCurrency.Text := Table.Currency;
  edtSymbol.Text := Table.Symbol;
  edtDescription.Text := Table.Description;
end;

end.
