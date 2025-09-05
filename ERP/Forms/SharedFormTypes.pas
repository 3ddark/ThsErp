unit SharedFormTypes;

interface

type
  TInputFormMode = (ifmNone, ifmNewRecord, ifmRewiev, ifmUpdate, ifmReadOnly, ifmCopyNewRecord);
  TAfterCrudRefreshGrid = procedure(AFocusSelectedItem: Boolean) of object;

implementation

end.
