unit PrdPacketLabour;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, PrdPacketLabourDetail;

type
  [Table('prd_packet_labour')]
  TPrdPacketLabour = class(TEntity)
  private
    // Kalemler (sahiplenir): servis yükler / yazar; durum TDetailEntity (Id işareti + Deleted)
    FLines: TObjectList<TPrdPacketLabourDetail>;
    FPacketName: string;

    // View (vw_prd_packet_labour) okunabilir alanları
    FItemCount: string;
  public
    [Column('packet_name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property PacketName: string read FPacketName write FPacketName;

    [NotMapped]
    property ItemCount: string read FItemCount write FItemCount;

    // Kolon değil (nesne özelliği): BusinessFindById ile dolar, BusinessSaveWithDetails ile yazılır
    property Lines: TObjectList<TPrdPacketLabourDetail> read FLines;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TPrdPacketLabour;
  end;

  // Kalemden başlığa tipli erişim: Line.Header.PacketName (HeaderEntity zayıf referans, sahiplenmez)
  TPrdPacketLabourDetailHelper = class helper for TPrdPacketLabourDetail
  private
    function GetHeader: TPrdPacketLabour;
    procedure SetHeader(const Value: TPrdPacketLabour);
  public
    property Header: TPrdPacketLabour read GetHeader write SetHeader;
  end;

implementation

{ TPrdPacketLabourDetailHelper }

function TPrdPacketLabourDetailHelper.GetHeader: TPrdPacketLabour;
begin
  Result := TPrdPacketLabour(HeaderEntity);
end;

procedure TPrdPacketLabourDetailHelper.SetHeader(const Value: TPrdPacketLabour);
begin
  HeaderEntity := Value;
end;

{ TPrdPacketLabour }

constructor TPrdPacketLabour.Create;
begin
  inherited;
  FLines := TObjectList<TPrdPacketLabourDetail>.Create(True);
end;

destructor TPrdPacketLabour.Destroy;
begin
  FLines.Free;
  inherited;
end;

// Kalemler dahil derin kopya; kopyanın kalemleri kopya başlığa bağlanır
function TPrdPacketLabour.Clone: TPrdPacketLabour;
var
  LLine, LCopy: TPrdPacketLabourDetail;
begin
  Result := TPrdPacketLabour.Create;
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
