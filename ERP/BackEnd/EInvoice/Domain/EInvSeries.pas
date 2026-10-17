unit EInvSeries;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, EInvLookup;

type
  [Table('einv_series')]
  TEInvSeries = class(TEntity)
  private
    FCode: string;
    FName: string;
    FSeriesScope: SmallInt;
    FIsDefault: Boolean;
    FIsActive: Boolean;

    // View (vw_einv_series) okunabilir alanları
    FLastNumber: string;
  public
    [Column('code')]
    [MaxLength(3), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('series_scope')]
    [Required()]
    property SeriesScope: SmallInt read FSeriesScope write FSeriesScope;

    [Column('is_default')]
    property IsDefault: Boolean read FIsDefault write FIsDefault;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    [NotMapped]
    property LastNumber: string read FLastNumber write FLastNumber;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvSeries;
  end;

implementation

constructor TEInvSeries.Create;
begin
  inherited;
  FIsActive := True;
  FSeriesScope := EINV_SERIES_INVOICE;
end;

destructor TEInvSeries.Destroy;
begin
  inherited;
end;

function TEInvSeries.Clone: TEInvSeries;
begin
  Result := TEInvSeries.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.SeriesScope := Self.SeriesScope;
  Result.IsDefault := Self.IsDefault;
  Result.IsActive := Self.IsActive;
  Result.LastNumber := Self.LastNumber;
end;

end.
