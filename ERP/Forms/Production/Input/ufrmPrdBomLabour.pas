unit ufrmPrdBomLabour;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomLabour.Service, PrdBomLabour;

type
  TfrmPrdBomLabour = class(TfrmInputSimpleDB<TPrdBomLabour, TPrdBomLabourService>)
    pnlContent: TPanel;
    lblPrdBomId: TLabel;
    edtPrdBomId: TEdit;
    lblPrdLabourId: TLabel;
    edtPrdLabourId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
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
  PrdBom, PrdBom.Service, ufrmPrdBoms,                                          // TfrmPrdBoms helper output form
  PrdLabour, PrdLabour.Service, ufrmPrdLabours;                                 // TfrmPrdLabours helper output form

procedure TfrmPrdBomLabour.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomLabour.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPrdLabourId.OnHelperProcess := HelperProcess;
  edtPrdBomId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
end;

procedure TfrmPrdBomLabour.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPrdBomLabour.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.TitleSingular, 'BoM Labour');
  lblPrdBomId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColPrdBomId, 'BoM');
  lblPrdLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColPrdLabourId, 'Labour / Cost');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomLabour.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdBomId: TfrmPrdBoms;
  LFrmPrdLabourId: TfrmPrdLabours;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPrdBomId.Name then
  begin
    LFrmPrdBomId := TfrmPrdBoms.Create(LEdit, TPrdBomService.Create, TPrdBom.Create);
    try
      LFrmPrdBomId.IsHelper := True;
      LFrmPrdBomId.ShowModal;
      if LFrmPrdBomId.DataTransfer then
        if LFrmPrdBomId.CleanAndClose then
        begin
          Table.PrdBomId := 0;
          Table.BomName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PrdBomId := LFrmPrdBomId.Table.Id;
          Table.BomName := LFrmPrdBomId.Table.BomName;
          LEdit.Text := Table.BomName;
        end;
    finally
      LFrmPrdBomId.Free;
    end;
  end
  else if LEdit.Name = edtPrdLabourId.Name then
  begin
    LFrmPrdLabourId := TfrmPrdLabours.Create(LEdit, TPrdLabourService.Create, TPrdLabour.Create);
    try
      LFrmPrdLabourId.IsHelper := True;
      LFrmPrdLabourId.ShowModal;
      if LFrmPrdLabourId.DataTransfer then
        if LFrmPrdLabourId.CleanAndClose then
        begin
          Table.PrdLabourId := 0;
          Table.LabourName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PrdLabourId := LFrmPrdLabourId.Table.Id;
          Table.LabourName := LFrmPrdLabourId.Table.Name;
          LEdit.Text := Table.LabourName;
        end;
    finally
      LFrmPrdLabourId.Free;
    end;
  end;
end;

procedure TfrmPrdBomLabour.RefreshData;
begin
  inherited;
  edtPrdBomId.Text := Table.BomName;
  edtPrdLabourId.Text := Table.LabourName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
