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
    lblcurrency: TLabel;
    lblsymbol: TLabel;
    lbldescription: TLabel;
    edtcurrency: TEdit;
    edtsymbol: TEdit;
    edtdescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCurrency.BtnAcceptClick(Sender: TObject);
begin
  Table.Currency := edtcurrency.Text;
  Table.Symbol := edtsymbol.Text;
  Table.Description :=  edtdescription.Text;
  inherited;
end;

procedure TfrmSysCurrency.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysCurrency.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Currency';

  edtcurrency.SetFocus;
end;

procedure TfrmSysCurrency.RefreshData;
begin
  inherited;
  edtcurrency.Text := Table.Currency;
  edtsymbol.Text := Table.Symbol;
  edtdescription.Text := Table.Description;
end;

end.

