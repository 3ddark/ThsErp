unit ufrmInputDetailedDB;

// Ana kayıt + detay (master-detail) giriş formu tabanı: üstte başlık (alt sınıfın DFM'indeki pnlContent, alTop),
// altta sekmeli detay alanı (PgcDetails); bir sekmede bir ya da yan yana birden çok detay grid'i (ör. borç / alacak).
// Table bir belgedir (başlık + kalem listeleri, ör. TSlsOffer.Lines): servis okurken kalemleri de getirir. Kalemler
// bellekte belge servisinin metotlarıyla eklenir / değişir / çıkar (TDetailSet + satır formu TfrmInputLineDB); F5
// Onayla Service.BusinessSaveWithDetails(Table) ile başlık + kalemleri tek transaction'da yazar. İnceleme -> Güncelle
// kaydı kilitleyip belgeyi yeniden okur ve kalemleri düzenlenebilir yapar; Kapat değişiklikleri bırakır (rollback).
// Kopya: Service.PrepareCopy(Table) (başlık ve kalemler yeni).
// Kısayollar: F5 Onayla, F6 Kapat, F7 satır ekle, Enter satırı aç, Ctrl+Del satır sil, PgUp / PgDn (incelemede)
// liste kayıtlarında gezinti.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Math, System.Generics.Collections, System.Generics.Defaults,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Entity, Service, SharedFormTypes, ufrmInputSimpleDB, Detail.Grid, Detail.Lines;

type
  TfrmInputDetailedDB<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TfrmInputSimpleDB<TE, TS>)
  private
    FPanelDetails: TPanel;
    FPgcDetails: TPageControl;
    FDetailSets: TList<IDetailSet>;
    FDetailObjects: TObjectList<TObject>;
    procedure CreateDetailArea;
    procedure DetailSetChanged(Sender: TObject);
    procedure PageResize(Sender: TObject);
    procedure LayoutPage(APage: TTabSheet);
    procedure UpdateDetailEditable;
    procedure SaveDocument;
    function ActiveDetailSet: IDetailSet;
    function DetailGridFocused: Boolean;
  protected
    // Yeni sekme (alt sınıf FormCreate'te)
    function AddDetailPage(const ACaption: string): TTabSheet;
    // Sekmeye kalem grid'i ekler (aynı sekmede ikincisi yan yana); küme forma aittir.
    // AViewName: kolon düzeni (sys_grid_column) için görünüm; AGetList: Table'ın kalem listesi (Table değişebilir,
    // her çağrıda okunur); ACreateLine / AAddLine / ARemoveLine: belge servisinin kalem işlemleri;
    // ALineForm: satır formunu oluşturur (modal, satırı sahiplenir)
    function AddDetail<TD: TDetailEntity, constructor>(APage: TTabSheet; const AViewName: string;
      const AGetList: TFunc<TObjectList<TD>>; const ACreateLine: TFunc<TD>; const AAddLine, ARemoveLine: TProc<TD>;
      const ALineForm: TDetailLineFormFactory<TD>): TDetailSet<TD>;
    // Kalemler değişti / yüklendi: başlıktaki toplamlar vb. (alt sınıf)
    procedure DetailsChanged; virtual;
    // Kalemler düzenlenebilir mi (yeni / kopya / güncelleme modları)
    function DetailsEditable: Boolean; virtual;
    // Table (belge) yüklendi / değişti: grid'ler yeniden dolar
    procedure RefreshDetails;
  public
    property PanelDetails: TPanel read FPanelDetails;
    property PgcDetails: TPageControl read FPgcDetails;
    property DetailSets: TList<IDetailSet> read FDetailSets;

    constructor Create(AOwner: TComponent; AService: TS; ATable: TE; AFormMode: TInputFormMode;
      ARefreshGridEvent: TAfterCrudRefreshGrid; AFormViewMode: TInputFormViewMode = ivmNormal;
      AOwnsService: Boolean = False); reintroduce; overload;
    destructor Destroy; override;

    procedure FormShow(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure ApplyLocalization; override;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure BtnSpinDownClick(Sender: TObject); override;
    procedure BtnSpinUpClick(Sender: TObject); override;
  end;

implementation

uses
  LocalizationManager, Ths.DialogHelper;

constructor TfrmInputDetailedDB<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; AFormMode: TInputFormMode;
  ARefreshGridEvent: TAfterCrudRefreshGrid; AFormViewMode: TInputFormViewMode; AOwnsService: Boolean);
begin
  FDetailSets := TList<IDetailSet>.Create;
  FDetailObjects := TObjectList<TObject>.Create(True);
  inherited Create(AOwner, AService, ATable, AFormMode, ARefreshGridEvent, AFormViewMode, AOwnsService);
  CreateDetailArea;
  Self.Constraints.MinWidth := Max(Self.Constraints.MinWidth, 760);
  Self.Constraints.MinHeight := Max(Self.Constraints.MinHeight, 480);
end;

destructor TfrmInputDetailedDB<TE, TS>.Destroy;
begin
  FDetailSets.Free;
  // kümeler (servisleriyle) önce; grid'ler form bileşeni olarak sonra
  FDetailObjects.Free;
  inherited;
end;

procedure TfrmInputDetailedDB<TE, TS>.CreateDetailArea;
begin
  FPanelDetails := TPanel.Create(Self);
  FPanelDetails.Name := 'pnlDetails';
  FPanelDetails.Caption := '';
  FPanelDetails.Parent := PanelMain;
  FPanelDetails.Align := alClient;
  FPanelDetails.BevelOuter := bvNone;
  FPanelDetails.ParentColor := True;
  FPanelDetails.AlignWithMargins := True;

  FPgcDetails := TPageControl.Create(Self);
  FPgcDetails.Name := 'pgcDetails';
  FPgcDetails.Parent := FPanelDetails;
  FPgcDetails.Align := alClient;
end;

function TfrmInputDetailedDB<TE, TS>.AddDetailPage(const ACaption: string): TTabSheet;
begin
  Result := TTabSheet.Create(Self);
  Result.PageControl := FPgcDetails;
  Result.Caption := ACaption;
  Result.OnResize := PageResize;
end;

function TfrmInputDetailedDB<TE, TS>.AddDetail<TD>(APage: TTabSheet; const AViewName: string;
  const AGetList: TFunc<TObjectList<TD>>; const ACreateLine: TFunc<TD>; const AAddLine, ARemoveLine: TProc<TD>;
  const ALineForm: TDetailLineFormFactory<TD>): TDetailSet<TD>;
var
  LGrid: TDetailGrid;
begin
  LGrid := TDetailGrid.Create(Self, APage, AViewName);
  Result := TDetailSet<TD>.Create(LGrid, AGetList, ACreateLine, AAddLine, ARemoveLine, ALineForm);
  Result.OnChanged := DetailSetChanged;
  FDetailObjects.Add(Result);
  FDetailSets.Add(Result);
  LayoutPage(APage);
end;

// Sekmedeki grid'ler eşit genişlikte yan yana (sonuncusu kalan alanı doldurur)
procedure TfrmInputDetailedDB<TE, TS>.LayoutPage(APage: TTabSheet);
var
  LGrids: TList<TDetailGrid>;
  LSet: IDetailSet;
  i, LWidth: Integer;
begin
  LGrids := TList<TDetailGrid>.Create;
  try
    for LSet in FDetailSets do
      if LSet.Grid.Container.Parent = APage then
        LGrids.Add(LSet.Grid);
    if LGrids.Count = 0 then
      Exit;
    LWidth := APage.ClientWidth div LGrids.Count;
    for i := 0 to LGrids.Count - 1 do
      if i < LGrids.Count - 1 then
      begin
        LGrids[i].Container.Align := alLeft;
        LGrids[i].Container.Left := i * LWidth;
        LGrids[i].Container.Width := LWidth;
      end
      else
        LGrids[i].Container.Align := alClient;
  finally
    LGrids.Free;
  end;
end;

procedure TfrmInputDetailedDB<TE, TS>.PageResize(Sender: TObject);
begin
  if Sender is TTabSheet then
    LayoutPage(TTabSheet(Sender));
end;

function TfrmInputDetailedDB<TE, TS>.DetailsEditable: Boolean;
begin
  Result := FormMode in [ifmNewRecord, ifmCopyNewRecord, ifmUpdate];
end;

procedure TfrmInputDetailedDB<TE, TS>.UpdateDetailEditable;
var
  LSet: IDetailSet;
begin
  for LSet in FDetailSets do
    LSet.SetEditable(DetailsEditable);
end;

procedure TfrmInputDetailedDB<TE, TS>.DetailSetChanged(Sender: TObject);
begin
  DetailsChanged;
end;

procedure TfrmInputDetailedDB<TE, TS>.DetailsChanged;
begin
//
end;

procedure TfrmInputDetailedDB<TE, TS>.RefreshDetails;
var
  LSet: IDetailSet;
begin
  for LSet in FDetailSets do
    LSet.Reset;
  UpdateDetailEditable;
  DetailsChanged;
end;

procedure TfrmInputDetailedDB<TE, TS>.FormShow(Sender: TObject);
var
  LSet: IDetailSet;
begin
  // kopya: başlık ve kalemler yeni kayıt olur (servis: id'ler, belge no, durum …)
  if FormMode = ifmCopyNewRecord then
    Service.PrepareCopy(Table);

  inherited;

  // başlık (alt sınıfın pnlContent'i FormCreate'te PanelMain'e taşınır) Tab sırasında detaylardan önce
  FPanelDetails.TabOrder := PanelMain.ControlCount - 1;
  for LSet in FDetailSets do
    LSet.Grid.LoadLayout(Service.UoW);
  RefreshDetails;
  if FPgcDetails.PageCount > 0 then
    FPgcDetails.ActivePageIndex := 0;
end;

procedure TfrmInputDetailedDB<TE, TS>.FormClose(Sender: TObject; var Action: TCloseAction);
var
  LSet: IDetailSet;
begin
  // önce güncelleme transaction'ı geri alınır (inherited); kolon düzeni transaction dışında yazılır
  inherited;
  for LSet in FDetailSets do
    try
      LSet.Grid.SaveLayout(Service.UoW);
    except
      // düzen yazılamazsa kapanış engellenmez
    end;
end;

procedure TfrmInputDetailedDB<TE, TS>.ApplyLocalization;
var
  LSet: IDetailSet;
begin
  inherited;
  if Assigned(FDetailSets) then
    for LSet in FDetailSets do
      LSet.Grid.ApplyLocalization;
end;

function TfrmInputDetailedDB<TE, TS>.ActiveDetailSet: IDetailSet;
var
  LSet: IDetailSet;
begin
  Result := nil;
  for LSet in FDetailSets do
    if LSet.Grid.Grid.Focused then
      Exit(LSet);
  if Assigned(FPgcDetails.ActivePage) then
    for LSet in FDetailSets do
      if LSet.Grid.Container.Parent = FPgcDetails.ActivePage then
        Exit(LSet);
end;

function TfrmInputDetailedDB<TE, TS>.DetailGridFocused: Boolean;
var
  LSet: IDetailSet;
begin
  Result := False;
  for LSet in FDetailSets do
    if LSet.Grid.Grid.Focused then
      Exit(True);
end;

procedure TfrmInputDetailedDB<TE, TS>.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LSet: IDetailSet;
begin
  if (Key = VK_F7) and (Shift = []) then
  begin
    Key := 0;
    LSet := ActiveDetailSet;
    if Assigned(LSet) and DetailsEditable then
      LSet.AddLine;
    Exit;
  end;
  // detay grid'inde PgUp / PgDn grid içinde kayar (liste kaydında gezinti değil)
  if ((Key = VK_PRIOR) or (Key = VK_NEXT)) and DetailGridFocused then
    Exit;
  inherited;
end;

procedure TfrmInputDetailedDB<TE, TS>.BtnAcceptClick(Sender: TObject);
begin
  if FormMode in [ifmNewRecord, ifmCopyNewRecord, ifmUpdate] then
  begin
    SaveDocument;
    Exit;
  end;

  // inceleme -> güncelleme: kayıt kilitlenir; belge (kalemler dahil) transaction içinde yeniden okunur
  inherited;
  if FormMode = ifmUpdate then
    RefreshDetails;
end;

procedure TfrmInputDetailedDB<TE, TS>.SaveDocument;
begin
  if not ValidateInput(PanelMain) then
    Exit;

  if (FormMode = ifmUpdate) and (TThsDialogHelper.CustomMsgDlg(
    TLocalizationManager.Translate(TLangKeys.TMessage.ConfirmUpdate, 'Are you sure you want to update the record?'),
    mtConfirmation, [mbYes, mbNo],
    [TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'), TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')) <> mrYes) then
    Exit;

  try
    Service.BusinessSaveWithDetails(Table, True, True);
    RefreshParentGrid(True);
    ModalResult := mrOk;
    Close;
  except
    ModalResult := mrNone;
    raise;
  end;
end;

procedure TfrmInputDetailedDB<TE, TS>.BtnSpinDownClick(Sender: TObject);
var
  LId: Int64;
begin
  LId := Table.Id;
  inherited;
  if Table.Id <> LId then
    RefreshDetails;
end;

procedure TfrmInputDetailedDB<TE, TS>.BtnSpinUpClick(Sender: TObject);
var
  LId: Int64;
begin
  LId := Table.Id;
  inherited;
  if Table.Id <> LId then
    RefreshDetails;
end;

end.
