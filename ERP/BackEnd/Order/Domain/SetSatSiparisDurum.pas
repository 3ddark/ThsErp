unit SetSatSiparisDurum;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sls_offer_status')]
  TSetSatSiparisDurum = class(TEntity)
  private
    FStatusCode: string;
    FAciklama: string;
  public
    [Column('id'), Required()]
    property Id: Int64 read FId write FId;

    [Column('status_code'), Required(), MaxLength(32)]
    property StatusCode: string read FStatusCode write FStatusCode;

    [Column('aciklama'), MaxLength(64)]
    property Aciklama: string read FAciklama write FAciklama;

    constructor Create(); override;
  end;

implementation

constructor TSetSatSiparisDurum.Create();
begin
  inherited;
end;

end.
