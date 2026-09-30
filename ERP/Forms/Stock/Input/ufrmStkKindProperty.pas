unit ufrmStkKindProperty;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkKindProperty.Service, StkKindProperty;

type
  TfrmStkKindProperty = class(TfrmInputSimpleDB<TStkKindProperty, TStkKindPropertyService>)
    pnlContent: TPanel;
    lblKind: TLabel;
    edtKind: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblStkKindFamilyId: TLabel;
    edtStkKindFamilyId: TEdit;
    lblS1: TLabel;
    edtS1: TEdit;
    lblS2: TLabel;
    edtS2: TEdit;
    lblS3: TLabel;
    edtS3: TEdit;
    lblS4: TLabel;
    edtS4: TEdit;
    lblS5: TLabel;
    edtS5: TEdit;
    lblS6: TLabel;
    edtS6: TEdit;
    lblS7: TLabel;
    edtS7: TEdit;
    lblS8: TLabel;
    edtS8: TEdit;
    lblS9: TLabel;
    edtS9: TEdit;
    lblS10: TLabel;
    edtS10: TEdit;
    lblI1: TLabel;
    edtI1: TEdit;
    lblI2: TLabel;
    edtI2: TEdit;
    lblI3: TLabel;
    edtI3: TEdit;
    lblI4: TLabel;
    edtI4: TEdit;
    lblI5: TLabel;
    edtI5: TEdit;
    lblD1: TLabel;
    edtD1: TEdit;
    lblD2: TLabel;
    edtD2: TEdit;
    lblD3: TLabel;
    edtD3: TEdit;
    lblD4: TLabel;
    edtD4: TEdit;
    lblD5: TLabel;
    edtD5: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  StkKindFamily, StkKindFamily.Service, ufrmStkKindFamilies;                    // TfrmStkKindFamilies helper output form

procedure TfrmStkKindProperty.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Kind := edtKind.Text;
  Table.Description := edtDescription.Text;
  Table.S1 := edtS1.Text;
  Table.S2 := edtS2.Text;
  Table.S3 := edtS3.Text;
  Table.S4 := edtS4.Text;
  Table.S5 := edtS5.Text;
  Table.S6 := edtS6.Text;
  Table.S7 := edtS7.Text;
  Table.S8 := edtS8.Text;
  Table.S9 := edtS9.Text;
  Table.S10 := edtS10.Text;
  Table.I1 := edtI1.Text;
  Table.I2 := edtI2.Text;
  Table.I3 := edtI3.Text;
  Table.I4 := edtI4.Text;
  Table.I5 := edtI5.Text;
  Table.D1 := edtD1.Text;
  Table.D2 := edtD2.Text;
  Table.D3 := edtD3.Text;
  Table.D4 := edtD4.Text;
  Table.D5 := edtD5.Text;
  inherited;
end;

procedure TfrmStkKindProperty.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkKindFamilyId.OnHelperProcess := HelperProcess;
  edtKind.thsInputDataType := itString;
  edtKind.CharCase := TEditCharCase.ecUpperCase;
  edtDescription.thsInputDataType := itString;
  edtS1.thsInputDataType := itString;
  edtS2.thsInputDataType := itString;
  edtS3.thsInputDataType := itString;
  edtS4.thsInputDataType := itString;
  edtS5.thsInputDataType := itString;
  edtS6.thsInputDataType := itString;
  edtS7.thsInputDataType := itString;
  edtS8.thsInputDataType := itString;
  edtS9.thsInputDataType := itString;
  edtS10.thsInputDataType := itString;
  edtI1.thsInputDataType := itString;
  edtI2.thsInputDataType := itString;
  edtI3.thsInputDataType := itString;
  edtI4.thsInputDataType := itString;
  edtI5.thsInputDataType := itString;
  edtD1.thsInputDataType := itString;
  edtD2.thsInputDataType := itString;
  edtD3.thsInputDataType := itString;
  edtD4.thsInputDataType := itString;
  edtD5.thsInputDataType := itString;
end;

procedure TfrmStkKindProperty.FormShow(Sender: TObject);
begin
  inherited;
  if edtKind.CanFocus then
    edtKind.SetFocus;
end;

procedure TfrmStkKindProperty.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.TitleSingular, 'Kind Property');
  lblKind.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColKind, 'Kind');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColDescription, 'Description');
  lblStkKindFamilyId.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColFamily, 'Family');
  lblS1.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS1, 'Text 1');
  lblS2.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS2, 'Text 2');
  lblS3.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS3, 'Text 3');
  lblS4.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS4, 'Text 4');
  lblS5.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS5, 'Text 5');
  lblS6.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS6, 'Text 6');
  lblS7.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS7, 'Text 7');
  lblS8.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS8, 'Text 8');
  lblS9.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS9, 'Text 9');
  lblS10.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS10, 'Text 10');
  lblI1.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI1, 'Integer 1');
  lblI2.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI2, 'Integer 2');
  lblI3.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI3, 'Integer 3');
  lblI4.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI4, 'Integer 4');
  lblI5.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI5, 'Integer 5');
  lblD1.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD1, 'Decimal 1');
  lblD2.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD2, 'Decimal 2');
  lblD3.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD3, 'Decimal 3');
  lblD4.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD4, 'Decimal 4');
  lblD5.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD5, 'Decimal 5');
end;

procedure TfrmStkKindProperty.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkKindFamilyId: TfrmStkKindFamilies;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkKindFamilyId.Name then
  begin
    LFrmStkKindFamilyId := TfrmStkKindFamilies.Create(LEdit, TStkKindFamilyService.Create, TStkKindFamily.Create);
    try
      LFrmStkKindFamilyId.IsHelper := True;
      LFrmStkKindFamilyId.ShowModal;
      if LFrmStkKindFamilyId.DataTransfer then
        if LFrmStkKindFamilyId.CleanAndClose then
        begin
          Table.StkKindFamilyId := 0;
          Table.FamilyName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkKindFamilyId := LFrmStkKindFamilyId.Table.Id;
          Table.FamilyName := LFrmStkKindFamilyId.Table.Family;
          LEdit.Text := Table.FamilyName;
        end;
    finally
      LFrmStkKindFamilyId.Free;
    end;
  end;
end;

procedure TfrmStkKindProperty.RefreshData;
begin
  inherited;
  edtKind.Text := Table.Kind;
  edtDescription.Text := Table.Description;
  edtStkKindFamilyId.Text := Table.FamilyName;
  edtS1.Text := Table.S1;
  edtS2.Text := Table.S2;
  edtS3.Text := Table.S3;
  edtS4.Text := Table.S4;
  edtS5.Text := Table.S5;
  edtS6.Text := Table.S6;
  edtS7.Text := Table.S7;
  edtS8.Text := Table.S8;
  edtS9.Text := Table.S9;
  edtS10.Text := Table.S10;
  edtI1.Text := Table.I1;
  edtI2.Text := Table.I2;
  edtI3.Text := Table.I3;
  edtI4.Text := Table.I4;
  edtI5.Text := Table.I5;
  edtD1.Text := Table.D1;
  edtD2.Text := Table.D2;
  edtD3.Text := Table.D3;
  edtD4.Text := Table.D4;
  edtD5.Text := Table.D5;
end;

end.
