unit ufrmFilterDBGrid;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Data.DB, Vcl.CheckLst, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, ufrmBase, Ths.Helper.Edit;

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
  ufrmBaseDBGrid, Ths.Constants, Ths.Globals;

{$R *.dfm}

constructor TFieldName.Create(AValue: string; ADataType: TFieldType);
begin
  FFieldName := AValue;
  FDataType := ADataType;
end;

procedure TfrmFilterDBGrid.btnAcceptClick(Sender: TObject);
var
  n1: Integer;
  LFilter, LFilterCriter: string;
  LStartLike, LEndLike: string;
begin
  if edtFilter.Text <> '' then
  begin
    LFilter := '';
    LFilterCriter := '';
    LStartLike := '';
    LEndLike := '';

    case rgFilterCriter.ItemIndex of
      0:
        LFilterCriter := '=';
      1:
        begin
          LFilterCriter := ' LIKE ';
          LStartLike := '%';
          LEndLike := '%';
        end;
      2:
        begin
          LFilterCriter := ' NOT LIKE ';
          LStartLike := '%';
          LEndLike := '%';
        end;
      3:
        begin
          LFilterCriter := ' LIKE ';
          LEndLike := '%';
        end;
      4:
        begin
          LFilterCriter := ' LIKE ';
          LStartLike := '%';
        end;
      5:
        LFilterCriter := '<>';
      6:
        LFilterCriter := '>';
      7:
        LFilterCriter := '<';
      8:
        LFilterCriter := '>=';
      9:
        LFilterCriter := '<=';
    end;

    for n1 := 0 to chklstFields.Items.Count - 1 do
    begin
      if chklstFields.Checked[n1] then
      begin
        if Assigned(chklstFields.Items.Objects[n1]) then
        begin
          if ((TFieldName(chklstFields.Items.Objects[n1]).FieldName <> '') and (TFieldName(chklstFields.Items.Objects[n1]).FieldName <> 'id')) or ((GSysKullanici.IsYonetici.Value) and (TFieldName(chklstFields.Items.Objects[n1]).FieldName = 'id')) then
          begin
            if LFilter <> '' then
              LFilter := LFilter + ' OR ';

            if (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftString)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftMemo)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftFmtMemo)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftFixedChar)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftWideString)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftWideMemo)
            or (TFieldName(chklstFields.Items.Objects[n1]).DataType = ftMemo)
            then
              LFilter := LFilter + TFieldName(chklstFields.Items.Objects[n1]).FieldName + LFilterCriter + QuotedStr(LStartLike + edtFilter.Text + LEndLike)
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
              LFilter := LFilter + TFieldName(chklstFields.Items.Objects[n1]).FieldName + LFilterCriter + QuotedStr(LStartLike + edtFilter.Text + LEndLike);
            end;
          end;
        end;
      end;
    end;

    if TfrmBaseDBGrid(ParentForm).FiltreGrid.Count > 0 then
      LFilter := ' AND ' + LFilter;

    TfrmBaseDBGrid(ParentForm).FiltreGrid.Add(LFilter);

    Close;
  end;
end;

procedure TfrmFilterDBGrid.FormCreate(Sender: TObject);
var
  n1, LIndex: Integer;
  LIDFiltrele: Boolean;
begin
  inherited;

  edtFilter.CharCase := ecNormal;

  btnAccept.Visible := True;
  edtFilter.Clear;

  LIDFiltrele := GSysKullanici.IsYonetici.Value;
  for n1 := 0 to TfrmBaseDBGrid(ParentForm).grd.Columns.Count - 1 do
  begin
    if LIDFiltrele or (TfrmBaseDBGrid(ParentForm).grd.Columns[n1].FieldName <> 'id') then
    begin
      LIndex := chklstFields.Items.AddObject(TfrmBaseDBGrid(ParentForm).grd.Columns[n1].Title.Caption, TFieldName.Create(TfrmBaseDBGrid(ParentForm).grd.Columns[n1].FieldName, TfrmBaseDBGrid(ParentForm).grd.Columns[n1].Field.DataType));

      if TfrmBaseDBGrid(ParentForm).grd.Columns[n1].FieldName = TfrmBaseDBGrid(ParentForm).grd.SelectedField.FieldName then
      begin
        chklstFields.Checked[LIndex] := True;
        if not TfrmBaseDBGrid(ParentForm).grd.SelectedField.IsNull then
          edtFilter.Text := TfrmBaseDBGrid(ParentForm).grd.SelectedField.Value;
      end;
    end;
  end;
end;

procedure TfrmFilterDBGrid.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);

  btnAccept.ImageIndex := IMG_FILTER;
  btnAccept.HotImageIndex := IMG_FILTER;

  edtFilter.CharCase := ecNormal;
  chklstFields.SetFocus;
  edtFilter.SetFocus;
end;

procedure TfrmFilterDBGrid.FormDestroy(Sender: TObject);
var
  n1: Integer;
begin
  for n1 := 0 to chklstFields.Items.Count - 1 do
    if Assigned(chklstFields.Items.Objects[n1]) then
      chklstFields.Items.Objects[n1].Free;

  inherited;
end;

end.

