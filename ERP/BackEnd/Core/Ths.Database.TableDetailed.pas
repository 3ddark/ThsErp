unit Ths.Database.TableDetailed;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  System.Generics.Collections,
  Data.DB,
  Ths.Database,
  Ths.Database.Table;

type
  TTableDetailed = class(TTable)
  protected
    procedure RefreshHeader; virtual; abstract;
    function ValidateDetay(ATable: TTable): Boolean; virtual; abstract;
  published
    ListDetay: TList;
    ListSilinenDetay: TList;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
    procedure FreeDetayListContent; virtual;
  public
    procedure CloneDetayLists(ADest: TTableDetailed);

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); virtual; abstract;
    procedure UpdateDetay(ATable: TTable); virtual; abstract;
    procedure RemoveDetay(ATable: TTable); virtual; abstract;
  end;

implementation

procedure TTableDetailed.CloneDetayLists(ADest: TTableDetailed);
var
  n1: Integer;
begin
  for n1 := 0 to ListDetay.Count -1 do
    ADest.ListDetay.Add(TTable(ListDetay[n1]).Clone);

  for n1 := 0 to ListSilinenDetay.Count -1 do
    ADest.ListSilinenDetay.Add(TTable(ListSilinenDetay[n1]).Clone);
end;

constructor TTableDetailed.Create(ADatabase: TDatabase);
begin
  inherited;

  ListDetay := TList.Create;
  ListDetay.Clear;

  ListSilinenDetay := TList.Create;
  ListSilinenDetay.Clear;
end;

destructor TTableDetailed.Destroy;
begin
  FreeDetayListContent;
  if Assigned(ListDetay) then
    FreeAndNil(ListDetay);
  if Assigned(ListSilinenDetay) then
    FreeAndNil(ListSilinenDetay);

  inherited;
end;

procedure TTableDetailed.FreeDetayListContent;
var
  n1: Integer;
begin
  if Assigned(ListDetay) then
    for n1 := ListDetay.Count-1 downto 0 do
    begin
      TTable(ListDetay[n1]).Free;
      ListDetay.Delete(n1);
    end;
  ListDetay.Clear;

  if Assigned(ListSilinenDetay) then
    for n1 := ListSilinenDetay.Count-1 downto 0 do
    begin
      TTable(ListSilinenDetay[n1]).Free;
      ListSilinenDetay.Delete(n1);
    end;
  ListSilinenDetay.Clear;
end;

end.
