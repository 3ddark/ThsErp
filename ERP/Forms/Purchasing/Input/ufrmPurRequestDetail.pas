unit ufrmPurRequestDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurRequestDetail.Service, PurRequestDetail;

type
  TfrmPurRequestDetail = class(TfrmInputSimpleDB<TPurRequestDetail, TPurRequestDetailService>)
    pnlContent: TPanel;
    lblPurRequestId: TLabel;
    edtPurRequestId: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblOrderedQuantity: TLabel;
    edtOrderedQuantity: TEdit;
    lblRequiredDate: TLabel;
    edtRequiredDate: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
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
  PurLookup,
  PurRequest, PurRequest.Service, ufrmPurRequests,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmPurRequestDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.RequiredDate := StrToDateDef(edtRequiredDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurRequestDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPurRequestId.OnHelperProcess := HelperProcess;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtRequiredDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurRequestDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtQuantity.CanFocus then
    edtQuantity.SetFocus;
end;

procedure TfrmPurRequestDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.TitleSingular, 'Request Line');
  lblPurRequestId.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColPurRequestId, 'Request');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColQuantity, 'Quantity');
  lblOrderedQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColOrderedQuantity, 'Ordered Quantity');
  lblRequiredDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRequiredDate, 'Required Date');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColDescription, 'Description');
end;

procedure TfrmPurRequestDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPurRequestId: TfrmPurRequests;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPurRequestId.Name then
  begin
    LFrmPurRequestId := TfrmPurRequests.Create(LEdit, TPurRequestService.Create, TPurRequest.Create);
    try
      LFrmPurRequestId.IsHelper := True;
      LFrmPurRequestId.ShowModal;
      if LFrmPurRequestId.DataTransfer then
        if LFrmPurRequestId.CleanAndClose then
        begin
          Table.PurRequestId := 0;
          Table.RequestNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurRequestId := LFrmPurRequestId.Table.Id;
          Table.RequestNo := LFrmPurRequestId.Table.RequestNo;
          LEdit.Text := Table.RequestNo;
        end;
    finally
      LFrmPurRequestId.Free;
    end;
  end
  else if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryCode := '';
          Table.InventoryName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

procedure TfrmPurRequestDetail.RefreshData;
begin
  inherited;
  edtPurRequestId.Text := Table.RequestNo;
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtOrderedQuantity.Text := CurrToStr(Table.OrderedQuantity);
  if Table.RequiredDate > 0 then
    edtRequiredDate.Text := DateToStr(Table.RequiredDate)
  else
    edtRequiredDate.Text := '';
  edtDescription.Text := Table.Description;
end;

end.
