unit ufrmTarihHaftaSecici;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInput;

type
  TfrmTarihHaftaSecici = class(TfrmBaseInput)
    lblyil: TLabel;
    edtyil: TEdit;
    lblhafta: TLabel;
    edthafta: TEdit;
    lblgun: TLabel;
    edtgun: TEdit;
    procedure edtyilKeyPress(Sender: TObject; var Key: Char);
    procedure edthaftaKeyPress(Sender: TObject; var Key: Char);
    procedure edtgunKeyPress(Sender: TObject; var Key: Char);
    procedure edtgunExit(Sender: TObject);
    procedure edthaftaExit(Sender: TObject);
  private
    FYil: Integer;
    FHafta: Integer;
    FGun: TDate;
    FTarih: string;
    FYilHafta, FYilHaftaIlkDeger: string;
  public
    property YilHafta: string read FYilHafta write FYilHafta;
    property Tarih: string read FTarih write FTarih;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure btnCloseClick(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormShow(Sender: TObject); override;
    procedure stbBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

{$R *.dfm}

procedure TfrmTarihHaftaSecici.btnAcceptClick(Sender: TObject);
begin
  //sonuc bu de�i�kenden d�necek �a��r�lan yerden bu de�i�kene ula�arak yeni y�l/hafta bilgisi elde edinilmi� olacak
  FYilHafta := edtYil.Text + '/' + edtHafta.Text;
  FTarih := edtGun.Text;
  Close;
  ModalResult := mrOk;
end;

procedure TfrmTarihHaftaSecici.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTarihHaftaSecici.edtgunExit(Sender: TObject);
var
  wYil, wAy, wHafta: Word; //Word olmak zorunda
begin
  inherited;

  if (edtGun.Text <> '') and (edtGun.Text <> '0') and (Length(edtGun.Text) = 10) then
    if Length(edtGun.Text) = 10 then
    begin
      DecodeDateWeek(StrToDate(edtGun.Text), wYil, wAy, wHafta);
      wYil := YearOf(StrToDate(edtGun.Text));
      wAy := MonthOf(StrToDate(edtGun.Text));
      wHafta := WeekOfTheYear(StrToDate(edtGun.Text));
      edtHafta.Text := (IntToStr(wHafta));
      edtYil.Text := IntToStr(wYil);
    end;
end;

procedure TfrmTarihHaftaSecici.edtgunKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  //0..9 aras� ve BackSpace haricindekileri alg�lama
  if (Key <> #8) and ((Key < '0') or (Key > '9')) then
    Key := #0;
  if Key = #13 then
  begin
    Key := #0;
    btnAccept.SetFocus;
  end
  else
  begin
    if Length(edtGun.Text) = 10 then
      Key := #0;
  end;
end;

procedure TfrmTarihHaftaSecici.edthaftaExit(Sender: TObject);
var
  h, y: word;
  t, secilentarih: string;
begin
  inherited;

  if (edtHafta.Text <> '0') and (edtHafta.Text <> '') and (StrToInt(edtHafta.Text) > 53) then
  begin
    ShowMessage('Yazılan Hafta Sayısı Maximum 52 Olabilir');
    secilentarih := edtHafta.Text;
    edtHafta.Text := '53';
    edtHafta.SetFocus;
    exit;
  end;

  if Length(edtHafta.Text) = 2 then
  begin
    if LeftStr(edtHafta.Text, 1) = '0' then
      edtHafta.Text := RightStr(edtHafta.Text, Length(edtHafta.Text) - 1);
  end;

  if (edtHafta.Text <> '') and (edtHafta.Text <> '0') then
  begin
    y := strToInt(edtYil.Text);
    h := strToInt(edtHafta.Text);
    try
      t := DateTimeToStr(EncodeDateWeek(y, h));
      t := DateToStr(IncDay(StrToDate(t), 4));
      edtGun.Text := t;
    except
      on E: Exception do
      begin
        E.Create(IntToStr(y) + ' y�l�nda ' + IntToStr(h) + ' hafta yoktur!');
        edtGun.Clear;
        t := '';
      end;
    end;
  end;
end;

procedure TfrmTarihHaftaSecici.edthaftaKeyPress(Sender: TObject; var Key: Char);
begin
  //0..9 aras� ve BackSpace haricindekileri alg�lama
  if (Key <> #8) and ((Key < '0') or (Key > '9')) then
    Key := #0;
  if Key = #13 then
  begin
    Key := #0;
    edtGun.SetFocus;
  end
  else
  begin
    if (Key <> #8) and (edtHafta.SelLength=0) and (Length(edtHafta.Text) = 2) then
      Key := #0;
  end;
end;

procedure TfrmTarihHaftaSecici.edtyilKeyPress(Sender: TObject; var Key: Char);
begin
  //0..9 aras� ve BackSpace haricindekileri alg�lama
  if (Key <> #8) and ((Key < '0') or (Key > '9')) then
    Key := #0;
  if Key = char(vk_return) then
    edtHafta.SetFocus
  else
  begin
    if Length(edtYil.Text) = 4 then
      Key := #0;
  end;
end;

procedure TfrmTarihHaftaSecici.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Self.Release;
end;

procedure TfrmTarihHaftaSecici.FormShow(Sender: TObject);
begin
  inherited;
  stbBase.Visible := False;
  btnAccept.Visible := True;
  btnAccept.Caption := 'Tamam';

  edtYil.ReadOnly := False;
  edtHafta.ReadOnly := False;
  edtGun.ReadOnly := False;
  edtGun.thsInputDataType := itDate;
  edtGun.thsActiveYear4Digit := GSysApplicationSetting.Donem.Value;

  FYilHaftaIlkDeger := FYilHafta;

  FYil := LeftStr(FYilHafta, 4).ToInteger;
  FHafta := MidStr(FYilHafta, 6, 2).ToInteger;
  FGun := IncDay( EncodeDateWeek(FYil, FHafta) , 4);

  edtYil.Text := FYil.ToString;
  edtHafta.Text := FHafta.ToString;
  edtGun.Text := DateToStr(FGun);
end;

procedure TfrmTarihHaftaSecici.stbBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
begin
  //
end;

end.
