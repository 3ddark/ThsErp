unit Ths.Utils.DatabaseTools;

interface

uses
  System.Classes, System.Types, System.SysUtils, System.IOUtils,
  Winapi.ShellAPI, Winapi.Windows, Vcl.Dialogs, Vcl.Controls,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Phys.PGDef, FireDAC.Comp.Client, FireDAC.Phys.PG,
  FireDAC.Comp.DataSet,
  Ths.Globals;

type
  TDatabaseTools = class
    /// <summary>
    ///  Mevcut sistemin PostgreSQL �zer�nden veritaban� yede�ini al�r
    /// </summary>
    class procedure DoDatabaseBackup;

    /// <summary>
    ///  PostgreSQL veritaban� yede�ini geri y�kler
    /// </summary>
    class procedure DoDatabaseRestore(ABackupFilePath, ADatabaseName: string);

    class procedure DoDatabaseCreate(ADatabaseName: string);
  end;

implementation

class procedure TDatabaseTools.DoDatabaseBackup;
var
  LParams, LFileName, LBackupDirectory, LToolsDirectory, LBackupTool: string;
begin
  if CustomMsgDlg('Veritaban� yede�ini almak istedi�inden emin misin?', TMsgDlgType.mtConfirmation, mbYesNo, ['Evet', 'Hay�r'], TMsgDlgBtn.mbNo, 'Yedek Alma Onay�') <> mrYes then
    Exit;

  LToolsDirectory := TPath.Combine(GUygulamaAnaDizin, 'Tools');
  LBackupTool := TPath.Combine(LToolsDirectory, 'backup.exe');
  LBackupDirectory := TPath.Combine(GUygulamaAnaDizin, 'Backups');
  LFileName := TPath.Combine(LBackupDirectory, FormatDateTime('YYYYMMDD_HHMMSS', Now));

  ForceDirectories(LToolsDirectory);
  ForceDirectories(LBackupDirectory);

  if not FileExists(LBackupTool) then
    raise Exception.Create('Yedekleme program� bulunamad�. L�tfen Tools dizini alt�ndaki yedekleme uygulamas�n� kontrol edin.');


  with GDataBase.Connection.Params as TFDPhysPGConnectionDefParams do
    LParams := '/c ' +
                LBackupTool +
                ' -Fc postgresql://' + UserName + ':' + Password + '@' +
                Server + ':' + Port.ToString + '/' + Database + ' > ' + LFileName + '&&exit';

  ShellExecute(0, 'open', 'cmd', PWideChar(LParams), nil, SW_HIDE);
  CustomMsgDlg(
    'Yedekleme i�lemi tamamland�.' + AddLBs(2) + 'Al�nan yedek dosyas� ' + LFileName,
    TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], ['Tamam'], TMsgDlgBtn.mbOK, 'Bilgilendirme');
end;

class procedure TDatabaseTools.DoDatabaseRestore(ABackupFilePath, ADatabaseName: string);
var
  LParams, LToolsDirectory, LAppName: string;
begin
  if CustomMsgDlg('Veritaban� yede�ini geri y�klemek istedi�inden emin misin?', TMsgDlgType.mtConfirmation, mbYesNo, ['Evet', 'Hay�r'], TMsgDlgBtn.mbNo, 'Yedek Geri Y�kleme Onay�') <> mrYes then
    Exit;

  LAppName := 'restore.exe';
  LToolsDirectory := TPath.Combine(GUygulamaAnaDizin, 'Tools');

  if not FileExists(TPath.Combine(LToolsDirectory, LAppName)) then
    raise Exception.Create('Yedek Geri Y�kleme program� bulunamad�. L�tfen Tools dizini alt�ndaki yedek geri y�kleme uygulamas�n� kontrol edin.');

  with GDataBase.Connection.Params as TFDPhysPGConnectionDefParams do
    LParams := '/c Tools\' +
               LAppName +
               ' -d postgresql://' + UserName + ':' + Password + '@' +
               Server + ':' + Port.ToString + '/' + ADatabaseName + ' ' + ABackupFilePath + '&&exit';

  ShellExecute(0, 'open', 'cmd', PWideChar(LParams), nil, SW_HIDE);
end;

class procedure TDatabaseTools.DoDatabaseCreate(ADatabaseName: string);
var
  LParams, LToolsDirectory, LAppName: string;
//  LHWND: HWND;
begin
  LAppName := 'createdb.exe';
  LToolsDirectory := TPath.Combine(GUygulamaAnaDizin, 'Tools');

  if not FileExists(TPath.Combine(LToolsDirectory, LAppName)) then
    raise Exception.Create('Veritabanı oluşturma programı bulunamadı. Lütfen Tools dizini altındaki veritabanı oluşturma uygulamasını("createdb.exe") kontrol edin.');

  with GDataBase.Connection.Params as TFDPhysPGConnectionDefParams do
    LParams :=
      '/c Tools\' + LAppName +
      ' -U ' + UserName +
      ' -h ' + Server +
      ' -P ' + Port.ToString +
      ' -w ' + ADatabaseName + '&&exit';

  //ShellExecute(LHWND, 'open', 'cmd', PWideChar(LParams), nil, SW_HIDE);
end;

end.
