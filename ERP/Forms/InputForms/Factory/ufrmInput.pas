unit ufrmInput;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, System.StrUtils,
  System.Math, System.Rtti, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls, Vcl.Grids,
  Vcl.ExtCtrls, Vcl.DBGrids, Data.DB, Vcl.Clipbrd,
  udm, FireDAC.Comp.Client,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  Ths.Orm.Table, Ths.Orm.Manager, Ths.Orm.ManagerStack;

type
  TfrmInput<T> = class(TForm)
  private
    FContext: PTEntityManager;
    FTable: T;
    FPTable: PThsTable;

    FBtnDelete: TButton;
    FContainer: TPanel;
    FBtnAccept: TButton;
    FPageControl: TPageControl;
    FTabSheetGeneral: TTabSheet;
    FStatus: TStatusBar;
    FFooter: TPanel;
    FBtnSpin: TSpinButton;
    FBtnClose: TButton;
    FFormMode: TInputFormMode;
    FDefaultSelectFilter: string;
    procedure SetContext(const Value: PTEntityManager);
    procedure SetTable(const Value: T);
    procedure SetPTable(const Value: PThsTable);
    procedure SetBtnAccept(const Value: TButton);
    procedure SetBtnClose(const Value: TButton);
    procedure SetBtnDelete(const Value: TButton);
    procedure SetBtnSpin(const Value: TSpinButton);
    procedure SetContainer(const Value: TPanel);
    procedure SetPageControl(const Value: TPageControl);
    procedure SetTabSheetGeneral(const Value: TTabSheet);
    procedure SetFooter(const Value: TPanel);
    procedure SetStatus(const Value: TStatusBar);
    procedure SetFormMode(const Value: TInputFormMode);

    function ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
  public
    property Context: PTEntityManager read FContext write SetContext;
    property Table: T read FTable write SetTable;
    property PTable: PThsTable read FPTable write SetPTable;
    property FormMode: TInputFormMode read FFormMode write SetFormMode;

    property Container: TPanel read FContainer write SetContainer;
    property PageControl: TPageControl read FPageControl write SetPageControl;
    property TabSheetGeneral: TTabSheet read FTabSheetGeneral write SetTabSheetGeneral;
    property Footer: TPanel read FFooter write SetFooter;
    property Status: TStatusBar read FStatus write SetStatus;
    property BtnSpin: TSpinButton read FBtnSpin write SetBtnSpin;
    property BtnAccept: TButton read FBtnAccept write SetBtnAccept;
    property BtnClose: TButton read FBtnClose write SetBtnClose;
    property BtnDelete: TButton read FBtnDelete write SetBtnDelete;

    procedure FormCreate(Sender: TObject); virtual;
    procedure FormDestroy(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure FormKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure FormPaint(Sender: TObject); virtual;
    procedure FormResize(Sender: TObject); virtual;
    procedure btnAcceptClick(Sender: TObject); virtual;
    procedure btnCloseClick(Sender: TObject); virtual;
    procedure btnDeleteClick(Sender: TObject); virtual;
    procedure SpinUpClick(Sender: TObject); virtual;
    procedure SpinDownClick(Sender: TObject); virtual;

    constructor Create(AOwner: TComponent; AContext: PTEntityManager; ATable: T; AFormMode: TInputFormMode; ACreateNewBase: Boolean = True); reintroduce; overload;
    procedure RefreshData(); virtual;
    function ValidateInput(AParentControl: TWinControl = nil): Boolean;
  end;

implementation

uses Ths.Constants, Ths.Globals;

procedure TfrmInput<T>.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
{    if Context.LogicalInsertOne(Table, True, WithCommitTransaction, False) then
    begin
      //RefreshParentGrid(True);
      ModalResult := mrOK;
      Close;
    end
    else
    begin
      ModalResult := mrNone;
      if (Table.Database.Connection.InTransaction) then
        Close;
    end;}
  end
  else if (FormMode = ifmUpdate) then
  begin
    if CustomMsgDlg('Kaydı güncelleme istediğinden emin misin?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      //Burada yeni kayıt veya güncelleme modunda olduğu için bütün kontrolleri açmak gerekiyor.
      //SetControlsDisabledOrEnabled(pnlMain, True);
      if PTable.LogicalUpdateOne(False, True, True) then
      begin
        //RefreshParentGrid(True);
        ModalResult := mrOK;
        Close;
      end
      else
      begin
        ModalResult := mrNone;
        BtnSpin.Visible := true;
        FormMode := ifmRewiev;
        BtnAccept.Caption := 'Güncelle';
        BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
        BtnAccept.Width := Max(100, BtnAccept.Width);
        btnDelete.Visible := false;
        Repaint;
      end;
    end;

  end
  else if (FormMode = ifmRewiev) then
  begin
    //burada güncelleme modunda olduğu için bütün kontrolleri açmak gerekiyor.
    //SetControlsDisabledOrEnabled(pnlMain, False);
    if (not Context.Connection.InTransaction) then
    begin
      //kayıt kilitle, eğer başka kullanıcı tarfından bu esnada silinmemişse
      if PTable.LogicalSelectOne(FDefaultSelectFilter, True, ( not Context.Connection.InTransaction), True) then
      begin
        //eğer aranan kayıt başka bir kullanıcı tarafından silinmişse count 0 kalır
        if not Assigned(PTable) then
        begin
          raise Exception.Create('Siz inceleme ekranındayken kayıt başka kullanıcı tarafından silinmiş.' + sLineBreak + sLineBreak + 'Kaydı tekrar kontrol edin!');
        end;

        btnSpin.Visible := false;
        FormMode := ifmUpdate;
        btnAccept.Caption := 'Onayla';
        btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
        btnAccept.Width := Max(100, btnAccept.Width);
        btnDelete.Visible := True;

        if Context.IsAuthorized(PTable.TableSourceCode, prtUpdate, True, False) then
          btnAccept.Enabled := True
        else
          btnAccept.Enabled := False;

        RefreshData;

        Repaint;

        //FocusFirstControl;

        btnDelete.Left := btnAccept.Left-btnDelete.Width;
      end;
    end
    else
      CustomMsgDlg('Aktif bir kayıt güncellemeniz var. Önce açık olan işleminizi bitirin!', mtError, [mbOK], ['Tamam'], mbOK, 'Bilgilendirme');
  end;
end;

procedure TfrmInput<T>.btnCloseClick(Sender: TObject);
begin
//
end;

procedure TfrmInput<T>.btnDeleteClick(Sender: TObject);
begin
//
end;

procedure TfrmInput<T>.SpinDownClick(Sender: TObject);
begin
//
end;

procedure TfrmInput<T>.SpinUpClick(Sender: TObject);
begin
//
end;

function TfrmInput<T>.ValidateInput(AParentControl: TWinControl): Boolean;
var
  n1, n2, nProcessCount: Integer;
  PanelContainer: TWinControl;
  LControlName: string;
begin
  nProcessCount := 0;
  nProcessCount := nProcessCount + 1;
  Result := true;
  PanelContainer := nil;

  if AParentControl = nil then
  begin
    PanelContainer := Container;
  end
  else
  begin
    if AParentControl.ClassType = TPanel then
      PanelContainer := AParentControl as TPanel
    else if AParentControl.ClassType = TGroupBox then
      PanelContainer := AParentControl as TGroupBox
    else if AParentControl.ClassType = TPageControl then
      PanelContainer := AParentControl as TPageControl
    else if AParentControl.ClassType = TTabSheet then
      PanelContainer := AParentControl as TTabSheet;
  end;

  if (FormMode=ifmUpdate) or (FormMode=ifmNewRecord) or (FormMode=ifmCopyNewRecord) then
  begin
    for n1 := 0 to PanelContainer.ControlCount -1 do
    begin
      if PanelContainer.Controls[n1].ClassType = TPanel then
        Result := ValidateSubControls(PanelContainer.Controls[n1] as TPanel, LControlName)
      else if PanelContainer.Controls[n1].ClassType = TGroupBox then
        Result := ValidateSubControls(PanelContainer.Controls[n1] as TGroupBox, LControlName)
      else if PanelContainer.Controls[n1].ClassType = TPageControl then
      begin
        for n2 := 0 to (PanelContainer.Controls[n1] as TPageControl).PageCount-1 do
        begin
          Result := ValidateSubControls((PanelContainer.Controls[n1] as TPageControl).Pages[n2], LControlName);
          if not Result then
            Break;
        end;
      end
      else if PanelContainer.Controls[n1].ClassType = TTabSheet then
        Result := ValidateSubControls(PanelContainer.Controls[n1] as TTabSheet, LControlName)
      else if PanelContainer.Controls[n1].ClassType = TEdit then
        Result := ValidateSubControls(TEdit(PanelContainer.Controls[n1]), LControlName)
      else if PanelContainer.Controls[n1].ClassType = TMemo then
        Result := ValidateSubControls(TMemo(PanelContainer.Controls[n1]), LControlName)
      else if PanelContainer.Controls[n1].ClassType = TCombobox then
        Result := ValidateSubControls(TCombobox(PanelContainer.Controls[n1]), LControlName);

      if not Result then
        Break;
    end;
  end;

  if (nProcessCount = 1) then
  begin
    Repaint;
    if (not Result) then
      raise Exception.Create('Zorunlu alanlar boş olamaz. Kırmızı renkli girişler zorunludur.' + sLineBreak + sLineBreak + sLineBreak + LControlName);
  end;
end;

function TfrmInput<T>.ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
var
  n1: Integer;
begin
  Result := True;
  if Sender.Visible then
  begin
    AControlName := Sender.Name;
    if (Sender.ClassType = TEdit)
    or (Sender.ClassType = TMemo)
    or (Sender.ClassType = TCombobox)
    then
    begin
      if Sender.ClassType = TEdit then
      begin
        if (TEdit(Sender).thsRequiredData) then
        begin
          if (TEdit(Sender).Text = '') then
          begin
            Result := False;
            TEdit(Sender).Repaint;
          end;
        end;
      end
      else if Sender.ClassType = TMemo then
      begin
        if (TMemo(Sender).thsRequiredData) then
        begin
          if (TMemo(Sender).Text = '') then
          begin
            Result := False;
            TMemo(Sender).Repaint;
          end;
        end;
      end
      else if Sender.ClassType = TCombobox then
      begin
        if (TCombobox(Sender).thsRequiredData) then
        begin
          if (TCombobox(Sender).Text  = '') then
          begin
            Result := False;
            TCombobox(Sender).Repaint;
          end;
        end;
      end;
    end
    else
    begin
      for n1 := 0 to Sender.ControlCount -1 do
      begin
        AControlName := Sender.Controls[n1].Name;
        if Sender.Controls[n1].ClassType = TEdit then
        begin
          if (TEdit(Sender.Controls[n1]).thsRequiredData) then
          begin
            if (TEdit(Sender.Controls[n1]).Text = '') then
            begin
              Result := False;
              TEdit(Sender.Controls[n1]).Repaint;
              Break;
            end;
          end;
        end
        else if Sender.Controls[n1].ClassType = TMemo then
        begin
          if (TMemo(Sender.Controls[n1]).thsRequiredData) then
          begin
            if (TMemo(Sender.Controls[n1]).Text = '') then
            begin
              Result := False;
              TMemo(Sender.Controls[n1]).Repaint;
              Break;
            end;
          end;
        end
        else if Sender.Controls[n1].ClassType = TCombobox then
        begin
          if (TCombobox(Sender.Controls[n1]).thsRequiredData) then
          begin
            if (TCombobox(Sender.Controls[n1]).Text  = '') then
            begin
              Result := False;
              TCombobox(Sender.Controls[n1]).Repaint;
              Break;
            end;
          end;
        end;
      end;
    end;
  end;
end;

constructor TfrmInput<T>.Create(AOwner: TComponent; AContext: PTEntityManager; ATable: T; AFormMode: TInputFormMode; ACreateNewBase: Boolean);
begin
  if ACreateNewBase then
    CreateNew(Owner);

  Self.Caption := 'Base Title';

  Context := AContext;
  FTable := ATable;
  PTable := @Table;
  FFormMode := AFormMode;

  Self.Position := poOwnerFormCenter;
  Self.KeyPreview := True;
  Self.Constraints.MinWidth := 640;
  Self.Constraints.MaxWidth := Monitor.Width;
  Self.Constraints.MinHeight := 480;
  Self.Constraints.MaxHeight := Monitor.Height;

  //form event
  Self.OnCreate := FormCreate;
  Self.OnDestroy := FormDestroy;
  Self.OnShow := FormShow;
  Self.OnClose := FormClose;
  Self.OnKeyPress := FormKeyPress;
  Self.OnKeyDown := FormKeyDown;
  Self.OnKeyUp := FormKeyUp;
  Self.OnPaint := FormPaint;
  Self.OnResize := FormResize;

  Container := TPanel.Create(Self);
  Container.Parent := Self;
  Container.Align := alClient;
  Container.BevelOuter := bvNone;
  Container.ParentColor := True;
  Container.Visible := True;

  PageControl := TPageControl.Create(Container);
  PageControl.Parent := Container;
  PageControl.Align := alClient;
  PageControl.Visible := True;

  TabSheetGeneral := TTabSheet.Create(PageControl);
  TabSheetGeneral.Parent := PageControl;
  TabSheetGeneral.PageControl := PageControl;
  TabSheetGeneral.TabVisible := True;
  TabSheetGeneral.Caption := 'General';
  PageControl.ActivePage := TabSheetGeneral;

  Footer := TPanel.Create(Container);
  Footer.Parent := Container;
  Footer.Align := alBottom;
  Footer.BevelOuter := bvNone;
  Footer.ParentColor := True;
  Footer.Height := 28;
  Footer.Visible := True;

  BtnSpin := TSpinButton.Create(Footer);
  BtnSpin.Parent := Footer;
  BtnSpin.Align := alLeft;
  BtnSpin.AlignWithMargins := True;
  BtnSpin.Margins.Left := 2;
  BtnSpin.Margins.Right := 2;
  BtnSpin.OnDownClick := SpinDownClick;
  BtnSpin.OnUpClick := SpinUpClick;
  BtnSpin.Visible := True;

  BtnClose := TButton.Create(Footer);
  BtnClose.Parent := Footer;
  BtnClose.Align := alRight;
  BtnClose.Caption := 'Close';
  BtnClose.Images := dm.il16;
  BtnClose.ImageIndex := IMG_CLOSE;
  BtnClose.AlignWithMargins := True;
  BtnClose.Margins.Left := 2;
  BtnClose.Margins.Right := 2;
  BtnClose.OnClick := btnCloseClick;
  BtnClose.Visible := False;

  BtnDelete := TButton.Create(Footer);
  BtnDelete.Parent := Footer;
  BtnDelete.Align := alLeft;
  BtnDelete.Caption := 'Delete';
  BtnDelete.Images := dm.il16;
  BtnDelete.ImageIndex := IMG_REMOVE;
  BtnDelete.AlignWithMargins := True;
  BtnDelete.Margins.Left := 2;
  BtnDelete.Margins.Right := 2;
  BtnDelete.OnClick := btnDeleteClick;
  BtnDelete.Visible := False;

  BtnAccept := TButton.Create(Footer);
  BtnAccept.Parent := Footer;
  BtnAccept.Align := alRight;
  BtnAccept.Caption := 'Tamam';
  BtnAccept.Images := dm.il16;
  BtnAccept.ImageIndex := IMG_ACCEPT;
  BtnAccept.AlignWithMargins := True;
  BtnAccept.Margins.Left := 2;
  BtnAccept.Margins.Right := 2;
  BtnAccept.OnClick := btnAcceptClick;
  BtnAccept.Visible := False;

  Status := TStatusBar.Create(Self);
  Status.Align := alBottom;
  Status.Parent := Self;
  with Status.Panels.Add do
  begin
    Width := 100;
  end;
end;

procedure TfrmInput<T>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Self.Release;
end;

procedure TfrmInput<T>.FormCreate(Sender: TObject);
begin
  if Assigned(PTable) then
  begin
    if PTable.Id.AsInteger > 0 then
      FDefaultSelectFilter := PTable.Id.QryName + '=' + PTable.Id.AsString;
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    btnClose.Visible := True;
    btnAccept.Visible := True;
    btnAccept.Caption := 'Onayla';
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
  end
  else if FormMode = ifmRewiev then
  begin
    btnClose.Visible := True;
    btnAccept.Visible := True;
    btnAccept.Left := btnAccept.Left-100;//alRight positon bug fixed most right close button

    btnAccept.Caption := 'Güncelle';
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
    btnDelete.Caption := 'Kayıt Sil';
    btnDelete.Width := Canvas.TextWidth(btnDelete.Caption) + 56;
    btnDelete.Width := Max(100, btnDelete.Width);
  end;
end;

procedure TfrmInput<T>.FormDestroy(Sender: TObject);
begin
  PTable.Free;

  Container.Free;
  Status.Free;
end;

procedure TfrmInput<T>.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F5 then
  begin
    ShowMessage('not implemented yet!' + sLineBreak + 'Shortcut F7 (Add New Record)');
  end
  else if Key = VK_F6 then
  begin
    Self.Close;
  end
  else if Key = VK_F11 then
  begin
    Self.AlphaBlend := not Self.AlphaBlend;
    Self.AlphaBlendValue := 50;
  end
end;

procedure TfrmInput<T>.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Self.Close;
  end;
end;

procedure TfrmInput<T>.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmInput<T>.FormPaint(Sender: TObject);
begin
//
end;

procedure TfrmInput<T>.FormResize(Sender: TObject);
begin
//
end;

procedure TfrmInput<T>.FormShow(Sender: TObject);
begin
  if PageControl.Visible and PageControl.Enabled and TabSheetGeneral.TabVisible and TabSheetGeneral.Enabled then
    PageControl.ActivePageIndex := TabSheetGeneral.TabIndex;

  if (FormMode <> ifmNewRecord) then
    RefreshData;
end;

procedure TfrmInput<T>.RefreshData;
begin
//
end;

procedure TfrmInput<T>.SetBtnAccept(const Value: TButton);
begin
  FBtnAccept := Value;
end;

procedure TfrmInput<T>.SetBtnClose(const Value: TButton);
begin
  FBtnClose := Value;
end;

procedure TfrmInput<T>.SetBtnDelete(const Value: TButton);
begin
  FBtnDelete := Value;
end;

procedure TfrmInput<T>.SetBtnSpin(const Value: TSpinButton);
begin
  FBtnSpin := Value;
end;

procedure TfrmInput<T>.SetContainer(const Value: TPanel);
begin
  FContainer := Value;
end;

procedure TfrmInput<T>.SetContext(const Value: PTEntityManager);
begin
  FContext := Value;
end;

procedure TfrmInput<T>.SetFooter(const Value: TPanel);
begin
  FFooter := Value;
end;

procedure TfrmInput<T>.SetFormMode(const Value: TInputFormMode);
begin
  FFormMode := Value;
end;

procedure TfrmInput<T>.SetPageControl(const Value: TPageControl);
begin
  FPageControl := Value;
end;

procedure TfrmInput<T>.SetPTable(const Value: PThsTable);
begin
  FPTable := Value;
end;

procedure TfrmInput<T>.SetStatus(const Value: TStatusBar);
begin
  FStatus := Value;
end;

procedure TfrmInput<T>.SetTable(const Value: T);
begin
  FTable := Value;
end;

procedure TfrmInput<T>.SetTabSheetGeneral(const Value: TTabSheet);
begin
  FTabSheetGeneral := Value;
end;

end.
