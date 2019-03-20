$title  An Illustrative PIES Model -- NLP Representation

*	Hogan, William (1975). Energy policy models for Project
*	Independence, Computers and Operations Research 2.

set     j       Consumption regions /j1, j2/
        i       Coal supply regions /i1, i2/
        k       Oil supply regions  /k1, k2/
        r       Refineries          /r1, r2/
        c       Increments for coal /L, M, H/,
        o       Increments for oil  /L, H/,
        p       Energy products         /Coal, Light, Heavy/,
        g(p)    Grades of refined oil / Light, Heavy/;

alias (p,pp);

table table1(i,c,*) Resource requirements for production levels (p 257)

*       cap     Production capacity (tons per day)
*       c0      Minimum price / ton ($)
*       newcap  New capital / ton
*       steel   Steel / ton

        cap     c0      newcap  steel
i1.L    300     5       1       1
i1.M    300     6       5       2
i1.H    400     8       10      3
i2.L    200     4       1       1
i2.M    300     5       5       4
i2.H    600     7       6       5;

table table2(i,j)  Transport costs ($ per ton)
                j1      j2
        i1      1.00    2.50
        i2      0.75    2.75;


table table3(k,o,*)  Oil resource requirements
                cap     c0      newcap  steel
        k1.L    1100    1       0       0
        k1.H    1200    1.5     10      4
        k2.L    1300    1.25    0       0
        k2.H    1100    1.50    15      2;

table table4(k,r)  Oil transport costs ($ per barrel)
                r1      r2
        k1      2       3
        k2      4       2;

table table5(*,r)       Refinery yields and cost
                        r1      r2
        Light           0.6     0.5
        Heavy           0.4     0.5
        cost            6.5     5.0;

table table6(r,j)  Transport costs for refined products ($ per barrel)
                j1      j2
        r1      1       1.2
        r2      1       1.5;

table  table7(p,*)  Elasticities of final demand
                RefP    RefQ    Light   Heavy   Coal
        Light   16      1200   -0.5     0.2     0.1
        Heavy   12      1000    0.1    -0.5     0.2
        Coal    12      1000    0.1     0.2    -0.75;

table  table8(p,j) Demand without K or S constraints
          j1        j2
light    1252      1266
heavy    1041      1055
coal     1102       998   ;

table  table9(p,j) Demand with  K or S constraints
          j1        j2
light    1205      1229
heavy     996      1020
coal      996       910   ;

parameter
	d0(p)           Reference demand,
	p0(p)           Reference price,
	sigma(p,pp)     Own- and cross-price elasticity matrix
	savail		Steel availability     /12000/,
	kavail		Capital availability   /35000/;

d0(p) = table7(p,"RefQ");
p0(p) = table7(p,"Refp");
sigma(p,pp) = table7(p,pp);

*	The model assumes the same demand function in all regions:

parameter	pref(p)		Reference price,
		qref(p)		Reference demand,
		epsilon(p)	Elasticity of demand (positive number);

pref(p) = table7(p,"refp");
qref(p) = table7(p,"refq");
epsilon(p) = abs(table7(p,p));


* unload data to use in the Julia/JuMP version
EXECUTE_UNLOAD "piesqcp_data.gdx",i,j,k,r,c,o,p,g,table1,table2,table3,table4,table5,table6,table7,table8,table9,pref,qref,epsilon,d0,p0,sigma,savail,kavail;
EXECUTE 'python3 ./gdx2json.py --in=piesqcp_data.gdx';


NONNEGATIVE
VARIABLES
	QC(i,c)		Quantity of coal extracted by region i at cost level c,
	QO(k,o)		Quantity of oil resources extracted -- region k at cost level o
	QR(r)		Quantity of oil refined -- refinery r,
	D(p,j)		Demand -- energy product p in consumption region j,
	XR(r,g,j)	Quantity of oil transported from refinery r to market j
	XC(i,j)		Quantity of coal transported from region i to market j
	XO(k,r)		Quantity of oil resources shipped from region k to refinery r
	TCOST		Transport cost,
	OCOST		Other costs
	CS		Consumer suplus;

VARIABLE	OBJ	Objective function (social surplus);

equations	oilresource, crudeoil, refinedoil, oildemand, coalsupply,
		coaldemand, transportcost, othercost, surplus, objdef;

oilresource(k)..	sum(o, QO(k,o)) =g= sum(r, XO(k,r));

*			Oil resource		Oil shipments
*			extraction

crudeoil(r)..		sum(k, XO(k,r)) =g= QR(r);

refinedoil(r,g)..	QR(r)*table5(g,r) =g= sum(j, XR(r,g,j));

oildemand(j,g)..	sum(r, XR(r,g,j)) =g= D(g,j);

coalsupply(i)..		sum(c, QC(i,c)) =g= sum(j, XC(i,j));

coaldemand(j)..		sum(i, XC(i,j)) =g= D("coal",j);

transportcost..		TCOST =e= sum((r,g,j), XR(r,g,j)*table6(r,j)) +
				  sum((k,r),   XO(k,r)*table4(k,r)) +
				  sum((i,j),   XC(i,j)*table2(i,j));

othercost..		OCOST =e= sum((k,o), QO(k,o)*table3(k,o,"c0")) +
				  sum((i,c), QC(i,c)*table1(i,c,"c0")) +
				  sum(r,     QR(r)*table5("cost",r));

*	First use a simple integrable demand function to define consumer surplus:

surplus..	CS =e= sum((p,j), D(p,j)*pref(p) * (1 + (1-D(p,j)/(2*qref(p))/epsilon(p))) );

objdef..	OBJ =e= CS - TCOST - OCOST;

QC.UP(i,c) = table1(i,c,"cap");
QO.UP(k,o) = table3(k,o,"cap");

MODEL pies /all/;

OPTION qcp=ipopt;
solve pies using QCP maximizing obj;

EXECUTE_UNLOAD "piesqcp_soln.gdx";
