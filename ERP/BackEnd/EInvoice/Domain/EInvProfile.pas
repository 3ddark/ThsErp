unit EInvProfile;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, EInvLookup;

type
  [Table('einv_profile')]
  TEInvProfile = class(TEntity)
  private
    FCode: string;
    FName: string;
    FDocumentKind: SmallInt;
    FRequiresExportInfo: Boolean;
    FIsActive: Boolean;
  public
    [Column('code')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('document_kind')]
    [Required()]
    property DocumentKind: SmallInt read FDocumentKind write FDocumentKind;

    [Column('requires_export_info')]
    property RequiresExportInfo: Boolean read FRequiresExportInfo write FRequiresExportInfo;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvProfile;
  end;

implementation

constructor TEInvProfile.Create;
begin
  inherited;
  FIsActive := True;
  FDocumentKind := EINV_DOC_INVOICE;
end;

destructor TEInvProfile.Destroy;
begin
  inherited;
end;

function TEInvProfile.Clone: TEInvProfile;
begin
  Result := TEInvProfile.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.DocumentKind := Self.DocumentKind;
  Result.RequiresExportInfo := Self.RequiresExportInfo;
  Result.IsActive := Self.IsActive;
end;

end.
