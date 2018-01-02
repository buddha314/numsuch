use Cdo,
    LinearAlgebra,
    LinearAlgebra.Sparse;

proc verticesFromPG(con: Connection, edgeTable: string, fromField: string, toField: string, wField: string) {
  return 0;
}

/*
 :arg n: number of distinct vertices.  If not provided, it will look into the table for the max of the feature ids.
 */
proc wFromPG(con: Connection, edgeTable: string
    , fromField: string, toField: string, wField: string, n: int) {
  var q = "SELECT %s, %s, %s FROM %s ORDER BY 1, 2;";
  var cursor = con.cursor();
  cursor.query(q,(fromField, toField, wField, edgeTable));
  const D: domain(2) = {1..n, 1..n};
  var SD: sparse subdomain(D) dmapped CS();
  var W: [SD] real;

  for row in cursor {
    SD += (row[fromField]: int, row[toField]:int);
    W[row[fromField]:int, row[toField]:int] = row[wField]: real;
  }
   return W;
}

proc vNamesFromPG(con: Connection, nameTable: string
  , nameField: string, idField: string ) {

  var cursor = con.cursor();
  var q1 = "SELECT max(%s) AS n FROM %s";
  cursor.query(q1, (idField, nameTable));
  var n:int= cursor.fetchone()['n']: int;
  var vertexNames: [1..n] string;

  var q2 = "SELECT %s, %s FROM %s ORDER BY 1";
  cursor.query(q2, (idField, nameField, nameTable));
  for row in cursor {
      vertexNames[row[idField]:int ] = row[nameField];
  }

  /*
  var q = "SELECT %s, %s, FROM %s ORDER BY 2"
  cursor.query(q, (nameField, idField, nameTable));
  */

  return vertexNames;

}
