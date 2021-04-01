unit Ths.Erp.Database.Singleton;

interface

{$I ThsERP.inc}

uses
  System.IniFiles,
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  System.Math,
  System.Variants,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ImgList,
  Vcl.Imaging.PngImage,
  Vcl.DBGrids,
  Data.FmtBcd,
  Data.DB,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKullanici,
  Ths.Erp.Database.Table.SysLisan,
  Ths.Erp.Database.Table.SysOndalikHane,
  Ths.Erp.Database.Table.SysUygulamaAyari,
  Ths.Erp.Database.Table.SysUygulamaAyariDiger,
  Ths.Erp.Database.Table.SysGun,
  Ths.Erp.Database.Table.SysAy;

const
  FERHAT_UYARI = ' [FERHAT => Dile göre çalýþmasýný saðla] ';

type
  TSingletonDB = class(TObject)
  strict private
    class var FInstance: TSingletonDB;
    constructor CreatePrivate;
  private
  public
    constructor Create;
    class function GetInstance(): TSingletonDB;

    destructor Destroy; override;

    function AddImalgeToImageList(pFileName: string; pList: TImageList; out pImageIndex: Integer): Boolean;

    function FillComboFromLangData(pComboBox: TComboBox; pBaseTableName, pBaseColName: string; pRowID: Integer): string;
  end;

var
  SingletonDB: TSingletonDB;
  vLangContent, vLangContent2: string;

implementation

uses
    Ths.Erp.Database.Table.SysGridFiltreSiralama
  , Ths.Erp.Constants
  , Ths.Erp.Globals
  , Ths.Erp.Database.Table.SysGridKolon
  , Ths.Erp.Database.Table.SysKaliteFormNo
  ;

function TSingletonDB.AddImalgeToImageList(pFileName: string; pList: TImageList;
  out pImageIndex: Integer): Boolean;
var
  mImage: TPicture;
  mImagePng: TPngImage;
  mBitmap: TBitmap;
Begin
  Result := False;
  pImageIndex := -1;
  if pList <> nil then
  begin
    if FileExists(pFilename, True) then
    begin
      mImage := TPicture.Create;
      mImagePng := TPngImage.Create;
      try
        try
          //dosya bulunamazsa hata vermemesi için try except yapýldý
          mImagePng.LoadFromFile(pFileName);
          mImage.Graphic := mImagePng;
        except
        end;


        if (mImage.Width > 0) and (mImage.Height > 0) then
        begin
          mBitmap := TBitmap.Create;
          try
            mBitmap.Assign(mImage.Graphic);

            pImageIndex := pList.add(mBitmap, nil);
            Result := True;
          finally
            mBitmap.Free;
          end;
        end
      finally
        mImage.Free;
        mImagePng.Free;
      end;
    end;
  end;
end;

constructor TSingletonDB.Create();
begin
  raise Exception.Create('Object Singleton');
end;

constructor TSingletonDB.CreatePrivate;
begin
  inherited Create;

  if GDataBase = nil then
    GDataBase := TDatabase.Create;

  if GSysKullanici = nil then
    GSysKullanici := TSysKullanici.Create(GDataBase);

  if GSysOndalikHane = nil then
    GSysOndalikHane := TSysOndalikHane.Create(GDataBase);

  if GSysUygulamaAyari = nil then
    GSysUygulamaAyari := TSysUygulamaAyari.Create(GDataBase);

  if GSysUygulamaAyariDiger = nil then
    GSysUygulamaAyariDiger := TSysUygulamaAyariDiger.Create(GDataBase);

  if GSysLisan = nil then
    GSysLisan := TSysLisan.Create(GDataBase);

  if GSysGun = nil then
    GSysGun := TSysGun.Create(GDataBase);

  if GSysAy = nil then
    GSysAy := TSysAy.Create(GDataBase);
end;

destructor TSingletonDB.Destroy();
begin
  if SingletonDB <> Self then
    SingletonDB := nil;

  inherited Destroy;
end;

class function TSingletonDB.GetInstance: TSingletonDB;
begin
  if not Assigned(FInstance) then
    FInstance := TSingletonDB.CreatePrivate;
  Result := FInstance;
end;

function TSingletonDB.FillComboFromLangData(pComboBox: TComboBox; pBaseTableName,
    pBaseColName: string; pRowID: Integer): string;
begin
  pComboBox.Clear;
  with GDataBase.NewQuery do
  try
    Close;
    SQL.Text :=
        'SELECT ' +
        ' CASE ' +
        '   WHEN b.val IS NULL THEN a.' + pBaseColName + ' ' +
        '   ELSE b.val ' +
        ' END as value ' +
        'FROM public.' + pBaseTableName + ' a ' +
        'LEFT JOIN sys_lang_data_content b ON b.row_id = a.id ' +
        '   AND b.table_name = ' + QuotedStr( ReplaceRealColOrTableNameTo(pBaseTableName) ) + ' ' +
        '   AND b.lang=' + QuotedStr(GDataBase.ConnSetting.Language);
    Open;
    while NOT EOF do
    begin
      pComboBox.Items.Add(Fields.Fields[0].AsString);
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

end.
