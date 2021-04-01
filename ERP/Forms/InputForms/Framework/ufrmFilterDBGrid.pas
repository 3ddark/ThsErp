unit ufrmFilterDBGrid;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Data.DB, Vcl.CheckLst, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin,

  ufrmBase,
  Ths.Erp.Helper.Edit;

type
  TFieldName = class
  private
    FFieldName: string;
    FDataType: TFieldType;
  public
    property FieldName: string read FFieldName write FFieldName;
    property DataType: TFieldType read FDataType write FDataType;

    constructor Create(AValue: string; ADataType: TFieldType);
  end;

type
  TfrmFilterDBGrid = class(TfrmBase)
    lblFields: TLabel;
    chklstFields: TCheckListBox;
    rgFilterCriter: TRadioGroup;
    Panel1: TPanel;
    lblFilterKeyValue: TLabel;
    edtFilter: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure chklstFieldsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  published
    procedure FormShow(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  ufrmBaseDBGrid, Ths.Erp.Database.Singleton, Ths.Erp.Constants, Ths.Erp.Functions;

{$R *.dfm}

{ TFieldName }

constructor TFieldName.Create(AValue: string; ADataType: TFieldType);
begin
  FFieldName := AValue;
  FDataType:= ADataType;
end;

procedure TfrmFilterDBGrid.btnAcceptClick(Sender: TObject);
var
  n1: Integer;
  vFilter, vFilterCriter: string;
  vStartLike, vEndLike: string;
begin
  if edtFilter.Text <> '' then
  begin
    vFilter := '';
    vFilterCriter := '';
    vStartLike := '';
    vEndLike := '';

    case rgFilterCriter.ItemIndex of
      0: vFilterCriter := '=';
      1: begin vFilterCriter := ' LIKE '; vStartLike := '%'; vEndLike := '%'; end;
      2: begin vFilterCriter := ' NOT LIKE '; vStartLike := '%'; vEndLike := '%'; end;
      3: begin vFilterCriter := ' LIKE '; vEndLike := '%'; end;
      4: begin vFilterCriter := ' LIKE '; vStartLike := '%'; end;
      5: vFilterCriter := '<>';
      6: vFilterCriter := '>';
      7: vFilterCriter := '<';
      8: vFilterCriter := '>=';
      9: vFilterCriter := '<=';
    end;

    for n1 := 0 to chklstFields.Items.Count-1 do
    begin
      if chklstFields.Checked[n1] then
      begin
        if Assigned(chklstFields.Items.Objects[n1]) then
        begin
          if ((TFieldName(chklstFields.Items.Objects[n1]).FieldName <> '') and (TFieldName(chklstFields.Items.Objects[n1]).FieldName <> 'id'))
          or ((TSingletonDB.GetInstance.User.IsAdmin.Value) and (TFieldName(chklstFields.Items.Objects[n1]).FieldName = 'id'))
          then
          begin
            if vFilter <> '' then
              vFilter := vFilter + ' OR ';

            if (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftString)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftMemo)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftFmtMemo)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftFixedChar)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftWideString)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftWideMemo)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftMemo)
            then
            begin
              vFilter := vFilter +
                         TFieldName(chklstFields.Items.Objects[n1]).FieldName +
                         vFilterCriter +
                         QuotedStr(vStartLike + edtFilter.Text + vEndLike);
            end
            else
            if (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftSmallint)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftInteger)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftShortint)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftWord)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftFloat)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftCurrency)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftLargeint)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftLongWord)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftTime)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftTimeStamp)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftDate)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftDateTime)
            then
            begin
              if  (rgFilterCriter.ItemIndex <> 1)
              and (rgFilterCriter.ItemIndex <> 2)
              and (rgFilterCriter.ItemIndex <> 3)
              and (rgFilterCriter.ItemIndex <> 4)
              then
                vFilter := vFilter + TFieldName(chklstFields.Items.Objects[n1]).FieldName + vFilterCriter + QuotedStr(vStartLike + edtFilter.Text + vEndLike);
            end;
          end;
        end;
      end;
    end;

    if vFilter <> '' then
    begin
      if TfrmBaseDBGrid(ParentForm).FilterGrid.Count > 0 then
        vFilter := ' AND ' + vFilter;
      TfrmBaseDBGrid(ParentForm).FilterGrid.Add(vFilter);
    end;

    Close;
  end;
end;

procedure TfrmFilterDBGrid.chklstFieldsDblClick(Sender: TObject);
begin
  chklstFields.Checked[chklstFields.ItemIndex] := not chklstFields.Checked[chklstFields.ItemIndex];
end;

procedure TfrmFilterDBGrid.FormCreate(Sender: TObject);
var
  n1: Integer;
  vIDCiksin: Boolean;
begin
  inherited;

  btnAccept.Visible := True;
  edtFilter.Clear;

  vIDCiksin := TSingletonDB.GetInstance.User.IsAdmin.Value;
  for n1 := 0 to TfrmBaseDBGrid(ParentForm).dbgrdBase.Columns.Count-1 do
  begin
    if vIDCiksin or (TfrmBaseDBGrid(ParentForm).dbgrdBase.Columns[n1].FieldName <> 'id') then
      if TfrmBaseDBGrid(ParentForm).dbgrdBase.Columns[n1].Field.DataType <> ftBoolean then
        chklstFields.AddItem(
            TfrmBaseDBGrid(ParentForm).dbgrdBase.Columns[n1].Title.Caption,
            TFieldName.Create(TfrmBaseDBGrid(ParentForm).dbgrdBase.Columns[n1].FieldName,
                              TfrmBaseDBGrid(ParentForm).dbgrdBase.Columns[n1].Field.DataType));
  end;
end;

procedure TfrmFilterDBGrid.FormShow(Sender: TObject);
begin
  inherited;

  rgFilterCriter.Items.Clear;
  rgFilterCriter.Items.Add('=');
  rgFilterCriter.Items.Add(TranslateText('like', FrameworkLang.FilterLike, LngFilter, LngSystem));
  rgFilterCriter.Items.Add(TranslateText('not like', FrameworkLang.FilterNotLike, LngFilter, LngSystem));
  rgFilterCriter.Items.Add(TranslateText('with start...', FrameworkLang.FilterWithStart, LngFilter, LngSystem));
  rgFilterCriter.Items.Add(TranslateText('...with end', FrameworkLang.FilterWithEnd, LngFilter, LngSystem));
  rgFilterCriter.Items.Add('<>');
  rgFilterCriter.Items.Add('>');
  rgFilterCriter.Items.Add('<');
  rgFilterCriter.Items.Add('>=');
  rgFilterCriter.Items.Add('<=');
  rgFilterCriter.ItemIndex := 1;

  lblFields.Caption := TranslateText(lblFields.Caption, FrameworkLang.FilterSelectFilterFields, LngFilter, LngSystem);
  btnAccept.Caption := TranslateText(btnAccept.Caption, FrameworkLang.ButtonFilter, LngButton, LngSystem);
  btnClose.Caption := TranslateText(btnClose.Caption, FrameworkLang.ButtonClose, LngButton, LngSystem);
  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);
  lblFilterKeyValue.Caption := TranslateText(lblFilterKeyValue.Caption, FrameworkLang.FilterKeyValue, LngFilter, LngSystem);
  rgFilterCriter.Caption := TranslateText(rgFilterCriter.Caption, FrameworkLang.FilterFilterCriteriaTitle, LngFilter, LngSystem);

  btnAccept.ImageIndex := IMG_FILTER;
  btnAccept.HotImageIndex := IMG_FILTER;

  edtFilter.CharCase := ecNormal;
  chklstFields.SetFocus;
end;

procedure TfrmFilterDBGrid.FormDestroy(Sender: TObject);
var
  n1: Integer;
begin
  for n1 := 0 to chklstFields.Items.Count-1 do
    if Assigned(chklstFields.Items.Objects[n1]) then
      chklstFields.Items.Objects[n1].Free;

  inherited;
end;

end.
