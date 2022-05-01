
DROP TABLE IF EXISTS OpenNGC; 

CREATE TABLE OpenNGC( Name TEXT,
Type TEXT,
RAhms TEXT,
Decdms TEXT,
Const TEXT,
MajAx TEXT,
MinAx TEXT,
PosAng TEXT,
B_Mag TEXT,
V_Mag TEXT,
J_Mag TEXT,
H_Mag TEXT,
K_Mag TEXT,
SurfBr TEXT,
Hubble TEXT,
Cstar_U_Mag TEXT,
Cstar_B_Mag TEXT,
Cstar_V_Mag TEXT,
M TEXT,
NGC TEXT,
IC TEXT,
Cstar_Names TEXT,
Identifiers TEXT,
Common_names TEXT,
NED_notes TEXT,
OpenNGC_notes TEXT
);
.separator ";"
.header on
.import NGC.csv OpenNGC

ALTER TABLE OpenNGC ADD COLUMN ra REAL;
ALTER TABLE OpenNGC ADD COLUMN dec REAL;
DELETE FROM OpenNGC WHERE Name LIKE 'Name';

CREATE UNIQUE INDEX index1 ON OpenNGC(Name);

