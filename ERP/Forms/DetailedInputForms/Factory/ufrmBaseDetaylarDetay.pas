unit ufrmBaseDetaylarDetay;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.Variants,
  System.Rtti, Vcl.Samples.Spin,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Dialogs, Vcl.Menus,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.AppEvnts, Vcl.Grids,
  Data.DB, FireDAC.Stan.Option, FireDAC.Stan.Intf,
  FireDAC.Comp.Client, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,

  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.StringGrid,

  ufrmBase,
  ufrmBaseInput,
  ufrmBaseDetaylar,

  Ths.Erp.Database.Table,
  Ths.Erp.Database.TableDetailed;

type
  TfrmBaseDetaylarDetay = class(TfrmBaseInput)
    procedure btnSpinDownClick(Sender: TObject);override;
    procedure btnSpinUpClick(Sender: TObject);override;
    procedure btnCloseClick(Sender: TObject);override;
    procedure btnDeleteClick(Sender: TObject);override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject);override;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
  private
    FGrid: TStringGrid;
  protected
  public
    constructor Create(
      AOwner: TComponent;
      AGrid: TStringGrid = nil;
      AParentForm: TForm = nil;
      ATable: TTable = nil;
      AFormMode: TInputFormMode = ifmNone;
      AFormDecimalMode: TFormDecimalMode = fomNormal;
      AFormViewMode: TInputFormViewMode = ivmNormal;
      AAcceptBtnDoAction: Boolean = True);reintroduce;overload;

    property Grid: TStringGrid read FGrid write FGrid;
  published
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

{$R *.dfm}

procedure TfrmBaseDetaylarDetay.btnSpinDownClick(Sender: TObject);
begin
  if FGrid <> nil then
  begin
    if (FGrid.Row < FGrid.RowCount-1) then
    begin
      FGrid.Row := FGrid.Row + 1;
      if Assigned(TTable(FGrid.Objects[COLUMN_GRID_OBJECT, FGrid.Row])) then
      begin
        Table := TTable(FGrid.Objects[COLUMN_GRID_OBJECT, FGrid.Row]);
        RefreshData;
      end;
    end;
  end;
end;

procedure TfrmBaseDetaylarDetay.btnSpinUpClick(Sender: TObject);
begin
  if FGrid <> nil then
  begin
    if (FGrid.Row-1 > FGrid.FixedRows-1) and (FGrid.RowCount > FGrid.FixedRows) then
    begin
      FGrid.Row := FGrid.Row - 1;
      if Assigned(TTable(FGrid.Objects[COLUMN_GRID_OBJECT, FGrid.Row])) then
      begin
        Table := TTable(FGrid.Objects[COLUMN_GRID_OBJECT, FGrid.Row]);
        RefreshData;
      end;
    end;
  end;
end;

constructor TfrmBaseDetaylarDetay.Create(
  AOwner: TComponent;
  AGrid: TStringGrid;
  AParentForm: TForm;
  ATable: TTable;
  AFormMode: TInputFormMode;
  AFormDecimalMode: TFormDecimalMode;
  AFormViewMode: TInputFormViewMode;
  AAcceptBtnDoAction: Boolean);
begin
  FGrid := AGrid;
  inherited Create(
    AOwner,
    AParentForm,
    ATable,
    AFormMode,
    AFormDecimalMode,
    AFormViewMode,
    AAcceptBtnDoAction
  );
end;

procedure TfrmBaseDetaylarDetay.btnCloseClick(Sender: TObject);
begin
  Self.Release;
end;

procedure TfrmBaseDetaylarDetay.btnDeleteClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) then
  begin
    TTableDetailed(TfrmBaseDetaylar(ParentForm).Table).RemoveDetay(Table);
    TfrmBaseDetaylar(ParentForm).RemoveDetay(Table, FGrid);
    Close();
  end;
end;

procedure TfrmBaseDetaylarDetay.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate) then
  begin
    TTableDetailed(TfrmBaseDetaylar(ParentForm).Table).UpdateDetay(Table);
    TfrmBaseDetaylar(ParentForm).UpdateDetay(Table, FGrid);
  end
  else if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    TTableDetailed(TfrmBaseDetaylar(ParentForm).Table).AddDetay(Table.Clone, True);
    TfrmBaseDetaylar(ParentForm).AddDetay(Table, FGrid);
  end;
  Close;
end;

procedure TfrmBaseDetaylarDetay.FormCreate(Sender: TObject);
begin
  inherited;

  if Assigned(Table) then
  begin
    SetControlDBProperty();
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    btnAccept.Visible := True;
    btnClose.Visible := True;
    btnAccept.Caption := TranslateText('CONFIRM', FrameworkLang.ButtonAccept, LngButton, LngSystem);

    //TRUE olarak gönder form ilk açýldýðýndan küçük-büyük harf ayarýný yap.
//    SetInputControlProperty(True);
  end
  else
  if (FormMode = ifmRewiev) then
  begin
    btnAccept.Visible := True;
    btnClose.Visible := True;

    btnAccept.Caption := TranslateText('UPDATE', FrameworkLang.ButtonUpdate, LngButton, LngSystem);
    btnDelete.Caption := TranslateText('DELETE', FrameworkLang.ButtonDelete, LngButton, LngSystem);
  end
  else
  if (FormMode = ifmUpdate) then
  begin
    btnAccept.Visible := True;
    btnClose.Visible := True;

    btnAccept.Caption := TranslateText('CONFIRM', FrameworkLang.ButtonAccept, LngButton, LngSystem);
    btnDelete.Caption := TranslateText('DELETE', FrameworkLang.ButtonDelete, LngButton, LngSystem);
  end;
end;

procedure TfrmBaseDetaylarDetay.FormDestroy(Sender: TObject);
begin
  frmConfirmation.Free;

  if FormMode = ifmNewRecord then
    Table.Free;
end;

procedure TfrmBaseDetaylarDetay.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (btnSpin.Visible) and (Key = VK_NEXT) then  //page_down
    btnSpinDownClick(btnSpin)
  else if (btnSpin.Visible) and (Key = VK_PRIOR) then  //page_up
    btnSpinUpClick(btnSpin)
  else
    inherited;
end;

procedure TfrmBaseDetaylarDetay.FormShow(Sender: TObject);
begin
  inherited;
  if (TfrmBaseDetaylar(ParentForm).FormMode = ifmRewiev)
  or (TfrmBaseDetaylar(ParentForm).FormMode = ifmReadOnly) then
  begin
    btnAccept.Visible := False;
  end
  else if (TfrmBaseDetaylar(ParentForm).FormMode = ifmUpdate) then
  begin
    if Self.FormMode = ifmUpdate then
      btnDelete.Visible := True;
  end
  else
  if (TfrmBaseDetaylar(ParentForm).FormMode = ifmNewRecord)
  or (TfrmBaseDetaylar(ParentForm).FormMode = ifmCopyNewRecord)
  then
  begin
    if Self.FormMode = ifmUpdate then
      btnDelete.Visible := True;
  end;

  if (TfrmBaseDetaylar(ParentForm).FormMode = ifmRewiev)
  or (TfrmBaseDetaylar(ParentForm).FormMode = ifmUpdate)
  or (TfrmBaseDetaylar(ParentForm).FormMode = ifmNewRecord)
  or (TfrmBaseDetaylar(ParentForm).FormMode = ifmCopyNewRecord)
  then
    RefreshData;
end;

end.
