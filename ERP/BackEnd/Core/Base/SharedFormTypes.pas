unit SharedFormTypes;

interface

uses
  System.Generics.Collections;

type
  TInputFormMode = (ifmNone, ifmNewRecord, ifmRewiev, ifmUpdate, ifmReadOnly, ifmCopyNewRecord);
  TInputFormViewMode = (ivmNormal, ivmSort);
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);

  TFormDecimalMode = (fomBuying, fomSale, fomStock, fomNormal);

  TAfterCrudRefreshGrid = procedure(AFocusSelectedItem: Boolean) of object;

implementation

end.
