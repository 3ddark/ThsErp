unit PrdPacketRaw;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, PrdPacketRawDetail;

type
  [Table('prd_packet_raw')]
  TPrdPacketRaw = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TPrdPacketRawDetail>;
    FPacketName: string;

    // View (vw_prd_packet_raw) okunabilir alanları
    FItemCount: string;
  public
    [Column('packet_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property PacketName: string read FPacketName write FPacketName;

    [NotMapped]
    property ItemCount: string read FItemCount write FItemCount;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TPrdPacketRawDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdPacketRaw;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.PacketName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdPacketRawDetailHelper = class helper for TPrdPacketRawDetail
  private
    function GetHeader: TPrdPacketRaw;
    procedure SetHeader(const Value: TPrdPacketRaw);
  public
    property Header: TPrdPacketRaw read GetHeader write SetHeader;
  end;

implementation

{ TPrdPacketRawDetailHelper }

function TPrdPacketRawDetailHelper.GetHeader: TPrdPacketRaw;
begin
  Result := TPrdPacketRaw(HeaderEntity);
end;

procedure TPrdPacketRawDetailHelper.SetHeader(const Value: TPrdPacketRaw);
begin
  HeaderEntity := Value;
end;

{ TPrdPacketRaw }

constructor TPrdPacketRaw.Create;
begin
  inherited;
  FLines := TObjectList<TPrdPacketRawDetail>.Create(True);
end;

destructor TPrdPacketRaw.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TPrdPacketRaw.Clone: TPrdPacketRaw;
var
  LLine, LCopy: TPrdPacketRawDetail;
begin
  Result := TPrdPacketRaw.Create;
  Result.Id := Self.Id;
  Result.PacketName := Self.PacketName;
  Result.ItemCount := Self.ItemCount;
  for LLine in Self.FLines do
  begin
    LCopy := LLine.Clone;
    LCopy.HeaderEntity := Result;
    Result.FLines.Add(LCopy);
  end;
end;

end.
