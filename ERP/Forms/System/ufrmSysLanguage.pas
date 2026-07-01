unit ufrmSysLanguage;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysLanguage.Service, SysLanguage;

type
  TfrmSysLanguage = class(TfrmInputSimpleDB<TSysLanguage, TSysLanguageService>)
    pnlContent: TPanel;
    lbllng_code: TLabel;
    lbldescription: TLabel;
    edtlng_code: TEdit;
    edtdescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysLanguage.BtnAcceptClick(Sender: TObject);
begin
  Table.LngCode := edtlng_code.Text;
  Table.Description := edtdescription.Text;
  inherited;
end;

procedure TfrmSysLanguage.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysLanguage.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Language';

  edtlng_code.SetFocus;
end;

procedure TfrmSysLanguage.InitializeInputCase;
begin
  inherited;
  edtlng_code.thsInputDataType := itString;
  edtlng_code.MaxLength := 2;
  edtdescription.thsInputDataType := itString;
  edtdescription.MaxLength := 128;
end;

procedure TfrmSysLanguage.RefreshData;
begin
  inherited;
  edtlng_code.Text := Table.LngCode;
  edtdescription.Text := Table.Description;
end;

end.
