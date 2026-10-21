unit ufrmPrdBomLabour;

// Reçete kalem satır formu (TfrmPrdBomDetail'den modal): bellekteki satırı düzenler, DB'ye reçeteyle birlikte yazılır.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBomLabour.Service, PrdBomLabour;

type
  TfrmPrdBomLabour = class(TfrmInputLineDB<TPrdBomLabour, TPrdBomLabourService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
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
  PrdLabour, PrdLabour.Service, ufrmPrdLabours;                                 // TfrmPrdLabours helper output form

procedure TfrmPrdBomLabour.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; başlık (belge) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  inherited;
end;

procedure TfrmPrdBomLabour.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtPrdLabourId.OnHelperProcess := HelperProcess;
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
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColLineNo, 'Line No');
  lblPrdLabourId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColPrdLabourId, 'Labour / Cost');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColQuantity, 'Quantity');
end;

procedure TfrmPrdBomLabour.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrdLabourId: TfrmPrdLabours;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPrdLabourId.Name then
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
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtPrdLabourId.Text := Table.LabourName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
end;

end.
