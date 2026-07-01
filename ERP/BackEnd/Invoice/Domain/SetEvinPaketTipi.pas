unit SetEvinPaketTipi;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('einv_packet_type')]
  TSetEvinPacketType = class(TEntity)
  private
    FCode: string;
    FPaketTypeName: string;
    FDescription: string;
  public
    [Column('code')]
    [Required]
    [MaxLength(32)]
    property Code: string read FCode write FCode;

    [Column('packet_type_name')]
    [Required]
    [MaxLength(64)]
    property PaketTypeName: string read FPaketTypeName write FPaketTypeName;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetEvinPacketType.Create();
begin
  inherited;
end;

destructor TSetEvinPacketType.Destroy;
begin
  inherited;
end;

end.
