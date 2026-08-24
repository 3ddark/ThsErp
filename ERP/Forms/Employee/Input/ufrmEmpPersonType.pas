unit ufrmEmpPersonType;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpPersonType.Service, EmpPersonType, LocalizationManager;

type
  TfrmEmpPersonType = class(TfrmInputSimpleDB<TEmpPersonType, TEmpPersonTypeService>)
    pnlContent: TPanel;
    lblPersonType: TLabel;
    edtPersonType: TEdit;
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

procedure TfrmEmpPersonType.BtnAcceptClick(Sender: TObject);
begin
  Table.PersonType := edtPersonType.Text;
  inherited;
end;

procedure TfrmEmpPersonType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmEmpPersonType.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtPersonType.SetFocus;
end;

procedure TfrmEmpPersonType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_person_type.title_singular', 'Personel Tipi');
  lblPersonType.Caption := TLocalizationManager.Translate('emp_person_type.lbl_person_type', 'Personel Tipi');
end;

procedure TfrmEmpPersonType.InitializeInputCase;
begin
  inherited;
  edtPersonType.thsInputDataType := itString;
  edtPersonType.MaxLength := 32;
end;

procedure TfrmEmpPersonType.RefreshData;
begin
  inherited;
  edtPersonType.Text := Table.PersonType;
end;

end.
