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
    lblLngCode: TLabel;
    lblDescription: TLabel;
    edtKod: TEdit;
    edtAciklama: TEdit;
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
  Table.Kod := edtKod.Text;
  Table.Aciklama := edtAciklama.Text;
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

  edtKod.SetFocus;
end;

procedure TfrmSysLanguage.InitializeInputCase;
begin
  inherited;
  edtKod.thsInputDataType := itString;
  edtKod.MaxLength := 2;
  edtAciklama.thsInputDataType := itString;
  edtAciklama.MaxLength := 128;
end;

procedure TfrmSysLanguage.RefreshData;
begin
  inherited;
  edtKod.Text := Table.Kod;
  edtAciklama.Text := Table.Aciklama;
end;

end.
