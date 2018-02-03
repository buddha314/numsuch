use NumSuch,
    Postgres,
    Time;

// PERFORMANCE BENCHMARKS FOR MATRIX DB INTERACTIONS

// RESULTS ARE AT THE BOTTOM OF THE FILE IN A MULTILINE COMMENT




config const DB_HOST: string = "localhost";
config const DB_USER: string = "postgres";
config const DB_NAME: string = "matops";
config const DB_PWD: string = "noether";
var con = PgConnectionFactory(host=DB_HOST, user=DB_USER, database=DB_NAME, passwd=DB_PWD);

var nameTable1 = "perftest3",
    idField = "ftr_id",
    nameField = "name",
    edgeTable1 = "perftest3",
    fromField = "from_id",
    toField = "to_id",
    wField = "w",
    wTable1 = "perftest1",
    n = 8;

var nameTable2 = "perftest4",
//    idField = "ftr_id",
//    nameField = "name",
    edgeTable2 = "perftest4",
//    fromField = "from_id",
//    toField = "to_id",
//    wField = "w",
    wTable2 = "perftest4";
    //    n = 8;

var nameTable3 = "perftest5",
//    idField = "ftr_id",
//    nameField = "name",
    edgeTable3 = "perftest5",
    //    fromField = "from_id",
    //    toField = "to_id",
    //    wField = "w",
    wTable3 = "perftest5";
    //    n = 8;

config param batchsize: int = 1000;


//GENERATING THE MATRIX. THE GENERATOR IS REALLY INEFFICIENT

var t5: Timer;
t5.start();
var X = generateRandomSparseMatrix(10000,0.90);
t5.stop();
writeln("  Generation time %n".format(t5.elapsed()));

//ONE COPY OF THE MATRIX GETS PERSISTED TO AN EMPTY TABLE 1
var t1: Timer;
t1.start();
persistSparseMatrix(con, aTable=wTable1, fromField=fromField, toField=toField, weightField=wField, A=X);
t1.stop();
writeln("  Batch Persistence time %n".format(t1.elapsed()));

//SECOND COPY GETS PERSISTED TO AN EMPTY TABLE 2
var t2: Timer;
t2.start();
persistSparseMatrix_(con, aTable=wTable2, fromField=fromField, toField=toField, weightField=wField, A=X);
t2.stop();
writeln("  Regular Persistence time %n".format(t2.elapsed()));

// LAST COPY GETS PERSISTED TO AN EMPTY TABLE 3
var t6: Timer;
t6.start();
persistSparseMatrix_(con, aTable=wTable3, fromField=fromField, toField=toField, weightField=wField, A=X);
t6.stop();
writeln("  Regular Persistence time %n".format(t6.elapsed()));


//INSERTION PERFORMANCE QUOTIENT
const delta1 = t1.elapsed()/t2.elapsed();
const delta3 = t6.elapsed()/t2.elapsed();

writeln("\n");
writeln("  Batch/Serial = %n".format(delta1));
writeln("  Parallel/Serial = %n".format(delta3));
writeln("\n");
writeln("\n");

// PARALLEL EXTRACTION TIME
var t3: Timer;
t3.start();
wFromPG(con=con, edgeTable=edgeTable1, fromField, toField, wField, n=10000);
t3.stop();
writeln("  Parallel Extraction time %n".format(t3.elapsed()));

// SERIAL EXTRACTION TIME
var t4: Timer;
t4.start();
wFromPG_(con=con, edgeTable=edgeTable2, fromField, toField, wField, n=10000);
t4.stop();
writeln("  Serial Extraction time %n".format(t4.elapsed()));

//EXTRACTION PERFORMANCE QUOTIENT
var delta2 = t3.elapsed()/t4.elapsed();

writeln("\n");
writeln("  Parallel/Serial %n".format(delta2));
writeln("\n");
writeln("\n");



/*
[Execution output was as follows:]
  Generation time 89.0169
  Batch Persistence time 0.634107
  Serial Persistence time 0.607571
  Parallel Persistence time 0.566482


  Batch/Serial = 1.04368
  Parallel/Serial = 0.932372





In these() standalone, creating 1 tasks
task 0 owns 0..1996===================
  Parallel Extraction time 0.064831
  Serial Extraction time 0.181858


  Parallel/Serial 0.356492

*/
