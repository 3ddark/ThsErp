unit SharedFormTypes;

interface

uses
  System.Generics.Collections, BaseEntity;

type
  TInputFormMode = (ifmNone, ifmNewRecord, ifmRewiev, ifmUpdate, ifmReadOnly, ifmCopyNewRecord);
  TAfterCrudRefreshGrid = procedure(AFocusSelectedItem: Boolean) of object;

implementation

end.
