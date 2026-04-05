unit SharedFormTypes;

interface

uses
  System.Generics.Collections;

type
  TInputFormMode = (ifmNone, ifmNewRecord, ifmRewiev, ifmUpdate, ifmReadOnly, ifmCopyNewRecord);
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);

  TAfterCrudRefreshGrid = procedure(AFocusSelectedItem: Boolean) of object;

implementation

end.
