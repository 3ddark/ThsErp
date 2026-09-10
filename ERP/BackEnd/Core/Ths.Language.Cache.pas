unit Ths.Language.Cache;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client;

type
  TLanguageInfo = record
    Id        : Int64;
    Locale    : string;
    NativeName: string;
  end;

  TLanguageCache = class
  strict private
    class var FLocales: TArray<TLanguageInfo>;
    class var FLoaded : Boolean;
    class constructor Create;
  public
    class procedure Load;
    class procedure Clear;
    class function  GetLocales: TArray<TLanguageInfo>;
    class function  IsLoaded: Boolean;
    class function  LocaleExists(const ALocale: string): Boolean;
    class function  GetIdByLocale(const ALocale: string): Int64;
    class function  GetLocaleById(AId: Int64): string;
  end;

implementation

uses
  UnitOfWork, Repository, SysLanguage, SysLanguage.Repository, Logger;

class constructor TLanguageCache.Create;
begin
  FLoaded := False;
  SetLength(FLocales, 0);
end;

class procedure TLanguageCache.Load;
var
  n1   : Integer;
  LInfo: TLanguageInfo;
  LLang: TSysLanguage;
  LRepo: IRepository<TSysLanguage>;
  LList: TList<TSysLanguage>;
begin
  if FLoaded then Exit;

  try
    LRepo := TUnitOfWork.Instance.GetRepository<TSysLanguage, TSysLanguageRepository>;
    LList := LRepo.Find(nil);
    try
      SetLength(FLocales, LList.Count);
      n1 := 0;
      for LLang in LList do
      begin
        LInfo.Id         := LLang.Id;
        LInfo.Locale     := LLang.Locale;
        LInfo.NativeName := LLang.NativeName;
        FLocales[n1]     := LInfo;
        Inc(n1);
      end;
      SetLength(FLocales, n1);
      FLoaded := True;
      GLogger.InfoFmt('TLanguageCache: %d dil yüklendi', [n1]);
    finally
      LList.Free;
    end;
  except
    on E: Exception do
      GLogger.ErrorFmt('TLanguageCache.Load hatasý: %s', [E.Message]);
  end;
end;

class procedure TLanguageCache.Clear;
begin
  SetLength(FLocales, 0);
  FLoaded := False;
end;

class function TLanguageCache.GetLocales: TArray<TLanguageInfo>;
begin
  Result := FLocales;
end;

class function TLanguageCache.IsLoaded: Boolean;
begin
  Result := FLoaded;
end;

class function TLanguageCache.LocaleExists(const ALocale: string): Boolean;
var
  LInfo: TLanguageInfo;
begin
  Result := False;
  for LInfo in FLocales do
    if SameText(LInfo.Locale, ALocale) then
      Exit(True);
end;

class function TLanguageCache.GetIdByLocale(const ALocale: string): Int64;
var
  LInfo: TLanguageInfo;
begin
  Result := 0;
  for LInfo in FLocales do
    if SameText(LInfo.Locale, ALocale) then
      Exit(LInfo.Id);
end;

class function TLanguageCache.GetLocaleById(AId: Int64): string;
var
  LInfo: TLanguageInfo;
begin
  Result := '';
  for LInfo in FLocales do
    if LInfo.Id = AId then
      Exit(LInfo.Locale);
end;

end.
