unit ufrmEmpUnit;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpUnit.Service, EmpUnit, LocalizationManager;

type
  TfrmEmpUnit = class(TfrmInputSimpleDB<TEmpUnit, TEmpUnitService>)
    pnlContent: TPanel;
    lblUnitName: TLabel;
    edtUnitName: TEdit;
    lblSectionId: TLabel;
    edtSectionId: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EmpSection, EmpSection.Service, ufrmEmpSections;

procedure TfrmEmpUnit.BtnAcceptClick(Sender: TObject);
begin
  Table.UnitName_ := edtUnitName.Text;
  inherited;
end;

procedure TfrmEmpUnit.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSectionId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEmpUnit.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtUnitName.SetFocus;
end;

procedure TfrmEmpUnit.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_unit.title_singular', 'Birim');
  lblUnitName.Caption := TLocalizationManager.Translate('emp_unit.lbl_unit_name', 'Birim Adı');
  lblSectionId.Caption := TLocalizationManager.Translate('emp_unit.lbl_section_id', 'Bölüm');
end;

procedure TfrmEmpUnit.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmSection: TfrmEmpSections;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtSectionId.Name then
    begin
      LFrmSection := TfrmEmpSections.Create(LEdit, TEmpSectionService.Create, TEmpSection.Create);
      try
        LFrmSection.IsHelper := True;
        LFrmSection.ShowModal;
        if LFrmSection.DataTransfer then
        begin
          if LFrmSection.CleanAndClose then
          begin
            Table.SectionId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.SectionId := LFrmSection.Table.Id;
            LEdit.Text := LFrmSection.Table.SectionName;
          end;
        end;
      finally
        LFrmSection.Free;
      end;
    end;
  end;
end;

procedure TfrmEmpUnit.InitializeInputCase;
begin
  inherited;
  edtUnitName.thsInputDataType := itString;
  edtSectionId.thsInputDataType := itInteger;
  edtUnitName.MaxLength := 32;
end;

procedure TfrmEmpUnit.RefreshData;
begin
  inherited;
  edtUnitName.Text := Table.UnitName_;
  if Assigned(Table.Section) then
    edtSectionId.Text := Table.Section.SectionName
  else
    edtSectionId.Text := '';
end;

end.
