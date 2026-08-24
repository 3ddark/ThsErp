unit CascadeHelper;

interface

uses Repository;

type
  TCascadeHelper = class
  public
    const
      None: TCascadeOperations = [];
      Insert: TCascadeOperations = [coInsert];
      Update: TCascadeOperations = [coUpdate];
      Delete: TCascadeOperations = [coDelete];

      InsertUpdate: TCascadeOperations = [coInsert, coUpdate];
      InsertDelete: TCascadeOperations = [coInsert, coDelete];
      UpdateDelete: TCascadeOperations = [coUpdate, coDelete];

      All: TCascadeOperations = [coInsert, coUpdate, coDelete];
  end;

implementation

end.
