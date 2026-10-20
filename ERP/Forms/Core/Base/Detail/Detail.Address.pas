unit Detail.Address;

// Belgeye ait ayrıntılı adresin düzenleyicisi (teklif, sipariş, irsaliye, fatura): bir TGroupBox içinde şehir (seçim,
// ülkesi şehirden gösterilir), ilçe, mahalle, semt, cadde, sokak, bina, kapı no, posta kodu. Kontroller kodla
// oluşturulur; değerler TSysAddress nesnesine LoadFrom / SaveTo ile taşınır (DB'ye yazmaz, kayıt belge servisinde).
// "Cari Adresinden Al" / "Temizle" düğmeleri olayla belge formuna bildirilir (cari adresi seçimi formdadır).
// Cari kartı (aeoContact, aeoFromAccount yok): web / e-posta satırı da gösterilir; Temizle olay yoksa yalnız kutuları
// boşaltır (DB'ye dokunmaz). aeoFromBilling: "Fatura Adresini Kullan" düğmesi (OnFromBilling; kopya AssignFrom ile).

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls, Vcl.Forms,
  Ths.Helper.Edit, SysAddress;

type
  TAddressEditorOption = (aeoFromAccount, aeoContact, aeoFromBilling);
  TAddressEditorOptions = set of TAddressEditorOption;

  TDocumentAddressEditor = class
  private
    FGroup: TGroupBox;
    FBtnFromAccount: TButton;
    FBtnClear: TButton;
    FBtnFromBilling: TButton;
    FCityId: Int64;
    FCityName: string;
    FCountryName: string;
    FEditable: Boolean;
    FRowCount: Integer;
    FEdits: array of TEdit;
    FLabels: array of TLabel;
    FOnFromAccount: TNotifyEvent;
    FOnClear: TNotifyEvent;
    FOnFromBilling: TNotifyEvent;
    function AddRow(ACol, ARow: Integer): TEdit;
    function Edit(AIndex: Integer): TEdit;
    procedure CityHelper(Sender: TObject);
    procedure FromAccountClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure FromBillingClick(Sender: TObject);
  public
    // AParent: sekme / kaydırma kutusu; grup kutusu üste hizalanır
    constructor Create(AOwner: TComponent; AParent: TWinControl; AOptions: TAddressEditorOptions = [aeoFromAccount]);
    procedure LoadFrom(AAddress: TSysAddress);
    // web / e-posta yalnız aeoContact ile yazılır (belge kopyasında kaynaktaki değer korunur)
    procedure SaveTo(AAddress: TSysAddress);
    procedure Clear;
    // Başka düzenleyicideki (ekrandaki, kaydedilmemiş) değerler kopyalanır
    procedure AssignFrom(ASource: TDocumentAddressEditor);
    procedure SetEditable(AValue: Boolean);
    procedure ApplyLocalization(const ACaption: string);
    property Group: TGroupBox read FGroup;
    property OnFromAccount: TNotifyEvent read FOnFromAccount write FOnFromAccount;
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
    property OnFromBilling: TNotifyEvent read FOnFromBilling write FOnFromBilling;
  end;

implementation

uses
  LocalizationManager, SysCity, SysCountry, SysCity.Service, ufrmSysCities;

const
  ROW_TOP = 52;
  ROW_HEIGHT = 25;
  LABEL_WIDTH = 110;
  EDIT_WIDTH = 250;
  COL_WIDTH = 380;
  ROW_COUNT = 5;
  ROW_COUNT_CONTACT = 6;

  // FEdits sırası (iki kolon, satır satır)
  E_CITY = 0;
  E_COUNTRY = 1;
  E_DISTRICT = 2;
  E_NEIGHBORHOOD = 3;
  E_QUARTER = 4;
  E_ROAD = 5;
  E_STREET = 6;
  E_BUILDING = 7;
  E_DOOR = 8;
  E_ZIP = 9;
  E_WEB = 10;
  E_EMAIL = 11;

constructor TDocumentAddressEditor.Create(AOwner: TComponent; AParent: TWinControl; AOptions: TAddressEditorOptions);

  function AddButton(AWidth: Integer; AOnClick: TNotifyEvent; AVisible: Boolean): TButton;
  begin
    Result := TButton.Create(AOwner);
    Result.Parent := FGroup;
    Result.SetBounds(8 + LABEL_WIDTH + 4, 20, AWidth, 25);
    Result.OnClick := AOnClick;
    Result.Visible := AVisible;
  end;

var
  I, LLeft: Integer;
  LButton: TButton;
begin
  inherited Create;
  FEditable := True;
  if aeoContact in AOptions then
    FRowCount := ROW_COUNT_CONTACT
  else
    FRowCount := ROW_COUNT;
  FGroup := TGroupBox.Create(AOwner);
  FGroup.Parent := AParent;
  FGroup.Align := alTop;
  FGroup.Height := ROW_TOP + FRowCount * ROW_HEIGHT + 8;
  FGroup.AlignWithMargins := True;

  // düğmeler soldan sağa, görünenler arka arkaya
  FBtnFromAccount := AddButton(170, FromAccountClick, aeoFromAccount in AOptions);
  FBtnFromBilling := AddButton(170, FromBillingClick, aeoFromBilling in AOptions);
  FBtnClear := AddButton(90, ClearClick, True);
  LLeft := 8 + LABEL_WIDTH + 4;
  for LButton in TArray<TButton>.Create(FBtnFromAccount, FBtnFromBilling, FBtnClear) do
    if LButton.Visible then
    begin
      LButton.Left := LLeft;
      Inc(LLeft, LButton.Width + 6);
    end;

  SetLength(FEdits, FRowCount * 2);
  SetLength(FLabels, FRowCount * 2);
  for I := 0 to FRowCount * 2 - 1 do
    FEdits[I] := AddRow(I mod 2, I div 2);

  Edit(E_CITY).ReadOnly := True;
  Edit(E_CITY).OnHelperProcess := CityHelper;
  Edit(E_COUNTRY).ReadOnly := True;
  Edit(E_COUNTRY).TabStop := False;
  // sys_address kolon uzunlukları
  for I in [E_DISTRICT, E_NEIGHBORHOOD, E_QUARTER, E_ROAD, E_STREET] do
    Edit(I).MaxLength := 64;
  Edit(E_BUILDING).MaxLength := 48;
  Edit(E_DOOR).MaxLength := 16;
  Edit(E_ZIP).MaxLength := 16;
  if FRowCount = ROW_COUNT_CONTACT then
  begin
    Edit(E_WEB).MaxLength := 64;
    Edit(E_EMAIL).MaxLength := 128;
  end;
end;

function TDocumentAddressEditor.AddRow(ACol, ARow: Integer): TEdit;
var
  LLabel: TLabel;
begin
  LLabel := TLabel.Create(FGroup.Owner);
  LLabel.Parent := FGroup;
  LLabel.AutoSize := False;
  LLabel.Alignment := taRightJustify;
  LLabel.SetBounds(8 + ACol * COL_WIDTH, ROW_TOP + ARow * ROW_HEIGHT + 4, LABEL_WIDTH, 13);
  LLabel.Font.Style := [fsBold];
  FLabels[ARow * 2 + ACol] := LLabel;

  Result := TEdit.Create(FGroup.Owner);
  Result.Parent := FGroup;
  Result.SetBounds(LLabel.Left + LABEL_WIDTH + 4, ROW_TOP + ARow * ROW_HEIGHT, EDIT_WIDTH, 22);
  Result.TabOrder := ARow * 2 + ACol + 3;   // önce üç düğme (cari adresi, fatura adresi, temizle)
end;

function TDocumentAddressEditor.Edit(AIndex: Integer): TEdit;
begin
  Result := FEdits[AIndex];
end;

procedure TDocumentAddressEditor.LoadFrom(AAddress: TSysAddress);
begin
  FCityId := AAddress.SysCityId;
  FCityName := '';
  FCountryName := '';
  if Assigned(AAddress.SysCity) then
  begin
    FCityName := AAddress.SysCity.CityName;
    if Assigned(AAddress.SysCity.SysCountry) then
      FCountryName := AAddress.SysCity.SysCountry.CountryName;
  end;
  Edit(E_CITY).Text := FCityName;
  Edit(E_COUNTRY).Text := FCountryName;
  Edit(E_DISTRICT).Text := AAddress.District;
  Edit(E_NEIGHBORHOOD).Text := AAddress.Neighborhood;
  Edit(E_QUARTER).Text := AAddress.Quarter;
  Edit(E_ROAD).Text := AAddress.Road;
  Edit(E_STREET).Text := AAddress.Street;
  Edit(E_BUILDING).Text := AAddress.BuildingName;
  Edit(E_DOOR).Text := AAddress.DoorNumber;
  Edit(E_ZIP).Text := AAddress.ZipCode;
  if FRowCount = ROW_COUNT_CONTACT then
  begin
    Edit(E_WEB).Text := AAddress.Web;
    Edit(E_EMAIL).Text := AAddress.Email;
  end;
end;

// id korunur (belgenin kayıtlı adresi güncellenir); şehir görüntü bilgisi de taşınır
procedure TDocumentAddressEditor.SaveTo(AAddress: TSysAddress);
begin
  AAddress.SysCityId := FCityId;
  AAddress.District := Edit(E_DISTRICT).Text;
  AAddress.Neighborhood := Edit(E_NEIGHBORHOOD).Text;
  AAddress.Quarter := Edit(E_QUARTER).Text;
  AAddress.Road := Edit(E_ROAD).Text;
  AAddress.Street := Edit(E_STREET).Text;
  AAddress.BuildingName := Edit(E_BUILDING).Text;
  AAddress.DoorNumber := Edit(E_DOOR).Text;
  AAddress.ZipCode := Edit(E_ZIP).Text;
  if FRowCount = ROW_COUNT_CONTACT then
  begin
    AAddress.Web := Edit(E_WEB).Text;
    AAddress.Email := Edit(E_EMAIL).Text;
  end;
  AAddress.SysCity.Free;
  AAddress.SysCity := nil;
  if FCityId > 0 then
  begin
    AAddress.SysCity := TSysCity.Create;
    AAddress.SysCity.Id := FCityId;
    AAddress.SysCity.CityName := FCityName;
    AAddress.SysCity.SysCountry.CountryName := FCountryName;
  end;
end;

procedure TDocumentAddressEditor.Clear;
var
  I: Integer;
begin
  FCityId := 0;
  FCityName := '';
  FCountryName := '';
  for I := 0 to High(FEdits) do
    FEdits[I].Text := '';
end;

procedure TDocumentAddressEditor.AssignFrom(ASource: TDocumentAddressEditor);
var
  I: Integer;
begin
  FCityId := ASource.FCityId;
  FCityName := ASource.FCityName;
  FCountryName := ASource.FCountryName;
  for I := 0 to High(FEdits) do
    if I <= High(ASource.FEdits) then
      FEdits[I].Text := ASource.FEdits[I].Text;
end;

procedure TDocumentAddressEditor.SetEditable(AValue: Boolean);
var
  I: Integer;
begin
  FEditable := AValue;
  FBtnFromAccount.Enabled := AValue;
  FBtnFromBilling.Enabled := AValue;
  FBtnClear.Enabled := AValue;
  for I := 0 to High(FEdits) do
    if not (I in [E_CITY, E_COUNTRY]) then
      FEdits[I].ReadOnly := not AValue;
  // form genelindeki kilit açma (ReadOnly := False) şehir / ülke alanlarını da açar: her zaman salt okunur
  Edit(E_CITY).ReadOnly := True;
  Edit(E_COUNTRY).ReadOnly := True;
end;

procedure TDocumentAddressEditor.ApplyLocalization(const ACaption: string);
begin
  FGroup.Caption := ' ' + ACaption + ' ';
  FBtnFromAccount.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentAddress.BtnFromAccount, 'From Account Address');
  FBtnClear.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentAddress.BtnClear, 'Clear');
  FBtnFromBilling.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentAddress.BtnFromBilling, 'Use Billing Address');
  FLabels[E_CITY].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColCity, 'City');
  FLabels[E_COUNTRY].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColCountry, 'Country');
  FLabels[E_DISTRICT].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDistrict, 'District');
  FLabels[E_NEIGHBORHOOD].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColNeighborhood, 'Neighborhood');
  FLabels[E_QUARTER].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColQuarter, 'Quarter');
  FLabels[E_ROAD].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColRoad, 'Road');
  FLabels[E_STREET].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColStreet, 'Street');
  FLabels[E_BUILDING].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColBuildingName, 'Building Name');
  FLabels[E_DOOR].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColDoorNumber, 'Door Number');
  FLabels[E_ZIP].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColZipCode, 'Zip Code');
  if FRowCount = ROW_COUNT_CONTACT then
  begin
    FLabels[E_WEB].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColWeb, 'Web');
    FLabels[E_EMAIL].Caption := TLocalizationManager.Translate(TLangKeys.TSysAddress.ColEmail, 'E-Mail');
  end;
end;

procedure TDocumentAddressEditor.CityHelper(Sender: TObject);
var
  LFrm: TfrmSysCities;
begin
  if not FEditable then
    Exit;
  LFrm := TfrmSysCities.Create(Edit(E_CITY), TSysCityService.Create, TSysCity.Create);
  try
    LFrm.IsHelper := True;
    LFrm.ShowModal;
    if LFrm.DataTransfer then
    begin
      if LFrm.CleanAndClose then
      begin
        FCityId := 0;
        FCityName := '';
        FCountryName := '';
      end
      else
      begin
        FCityId := LFrm.Table.Id;
        FCityName := LFrm.Table.CityName;
        FCountryName := '';
        if Assigned(LFrm.Table.SysCountry) then
          FCountryName := LFrm.Table.SysCountry.CountryName;
      end;
      Edit(E_CITY).Text := FCityName;
      Edit(E_COUNTRY).Text := FCountryName;
    end;
  finally
    LFrm.Free;
  end;
end;

procedure TDocumentAddressEditor.FromAccountClick(Sender: TObject);
begin
  if Assigned(FOnFromAccount) then
    FOnFromAccount(Self);
end;

procedure TDocumentAddressEditor.FromBillingClick(Sender: TObject);
begin
  if FEditable and Assigned(FOnFromBilling) then
    FOnFromBilling(Self);
end;

procedure TDocumentAddressEditor.ClearClick(Sender: TObject);
begin
  if Assigned(FOnClear) then
    FOnClear(Self)
  else if FEditable then
    Clear;
end;

end.
