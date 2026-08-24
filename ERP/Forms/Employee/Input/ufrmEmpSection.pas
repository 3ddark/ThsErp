unit ufrmEmpSection;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpSection.Service, EmpSection, LocalizationManager;

type
  TfrmEmpSection = class(TfrmInputSimpleDB<TEmpSection, TEmpSectionService>)
    pnlContent: TPanel;
    lblSectionName: TLabel;
    edtSectionName: TEdit;
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

procedure TfrmEmpSection.BtnAcceptClick(Sender: TObject);
begin
  Table.SectionName := edtSectionName.Text;
  inherited;
end;

procedure TfrmEmpSection.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmEmpSection.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtSectionName.SetFocus;
end;

procedure TfrmEmpSection.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_section.title_singular', 'Bölüm');
  lblSectionName.Caption := TLocalizationManager.Translate('emp_section.lbl_section_name', 'Bölüm Adı');
end;

procedure TfrmEmpSection.InitializeInputCase;
begin
  inherited;
  edtSectionName.thsInputDataType := itString;
  edtSectionName.MaxLength := 32;
end;

procedure TfrmEmpSection.RefreshData;
begin
  inherited;
  edtSectionName.Text := Table.SectionName;
end;

end.
