unit ufrmSatSiparislerRapor;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.StrUtils,
  System.DateUtils, Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus,
  Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin,
  Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, ufrmBase, ufrmBaseDBGrid,
  System.Actions, Vcl.ActnList, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmSatSiparislerRapor = class(TfrmBaseDBGrid)
    rgFiltre: TRadioGroup;
    procedure HizliFiltre(Sender: TObject);
  private
    FHizliFilterActive: Boolean;
    FHizliFilter: string;
  public
    procedure ShowInputForm(Sender: TObject; pFormType: TInputFormMode); override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

const
  FILTER_GECMIS = 0;
  FILTER_GELECEK_AY = 1;
  FILTER_GECEN_AY = 2;
  FILTER_BU_HAFTA = 3;
  FILTER_SONRAKI_HAFTA = 4;
  FILTER_TUMU = 5;

implementation

uses
  ufrmSatSiparisDetaylar,
  Ths.Globals,
  Ths.Database.Table.SatSiparisRapor;

{$R *.dfm}

procedure TfrmSatSiparislerRapor.FormShow(Sender: TObject);
begin
  inherited;
  btnAddNew.Visible := False;
  mnicopy_record.OnClick := nil;

  FHizliFilterActive := False;
  rgFiltre.ItemIndex := 0;
  FHizliFilterActive := True;
  HizliFiltre(nil);
end;

procedure TfrmSatSiparislerRapor.HizliFiltre(Sender: TObject);
var
  LDate, LDate2: TDate;
begin
  if not IsHelper then
  begin
    if FHizliFilterActive then
    begin
      grd.DataSource.DataSet.DisableControls;
      try
        FHizliFilterActive := False;
        grd.DataSource.DataSet.Filter := ReplaceStr(grd.DataSource.DataSet.Filter, FHizliFilter, '');

        LDate := Now;

        FHizliFilter := '';

        if rgFiltre.ItemIndex = FILTER_GECMIS then
          FHizliFilter := TSatSiparisRapor(Table).SiparisTarihi.FieldName + '<' + QuotedStr(DateToStr(LDate))
        else if rgFiltre.ItemIndex = FILTER_GELECEK_AY then
        begin
          LDate := StartOfTheMonth(IncMonth(Now));
          LDate2 := EndOfTheMonth(LDate);
          FHizliFilter := TSatSiparisRapor(Table).SiparisTarihi.FieldName + '>=' + QuotedStr(DateToStr(LDate)) + ' AND ' +
                          TSatSiparisRapor(Table).SiparisTarihi.FieldName + '<=' + QuotedStr(DateToStr(LDate2));
        end
        else if rgFiltre.ItemIndex = FILTER_GECEN_AY then
        begin
          LDate := StartOfTheMonth(IncMonth(Now, -1));
          LDate2 := EndOfTheMonth(LDate);
          FHizliFilter := TSatSiparisRapor(Table).SiparisTarihi.FieldName + '>=' + QuotedStr(DateToStr(LDate)) + ' AND ' +
                          TSatSiparisRapor(Table).SiparisTarihi.FieldName + '<=' + QuotedStr(DateToStr(LDate2));
        end
        else if rgFiltre.ItemIndex = FILTER_BU_HAFTA then
        begin
          LDate := StartOfTheWeek(Now);
          LDate2 := EndOfTheWeek(LDate);
          FHizliFilter := TSatSiparisRapor(Table).SiparisTarihi.FieldName + '>=' + QuotedStr(DateToStr(LDate)) + ' AND ' +
                          TSatSiparisRapor(Table).SiparisTarihi.FieldName + '<=' + QuotedStr(DateToStr(LDate2))
        end
        else if rgFiltre.ItemIndex = FILTER_SONRAKI_HAFTA then
        begin
          LDate := StartOfTheWeek(IncWeek(Now));
          LDate2 := EndOfTheWeek(LDate);
          FHizliFilter := TSatSiparisRapor(Table).SiparisTarihi.FieldName + '>=' + QuotedStr(DateToStr(LDate)) + ' AND ' +
                          TSatSiparisRapor(Table).SiparisTarihi.FieldName + '<=' + QuotedStr(DateToStr(LDate2))
        end
        else if rgFiltre.ItemIndex = FILTER_TUMU then
          FHizliFilter := '';


        if grd.DataSource.DataSet.Filter <> '' then
          FHizliFilter := ' AND ' + FHizliFilter;
        grd.DataSource.DataSet.Filter := FHizliFilter;
        if grd.DataSource.DataSet.Filter <> '' then
          grd.DataSource.DataSet.Filtered := True;

      finally
        FHizliFilterActive := True;
        grd.DataSource.DataSet.EnableControls;
      end;
    end;
  end;
end;

procedure TfrmSatSiparislerRapor.ShowInputForm(Sender: TObject; pFormType: TInputFormMode);
begin
  //
end;

end.
