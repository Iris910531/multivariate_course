%let indir=C:\Users\user\Desktop\resume\datasets;

proc import datafile="&indir\mtcars.csv" out=dshw dbms=csv replace; 
getnames=yes;
run;

proc print data=dshw(obs=5);
run;

/*scatter plot - using picture to see whether there are correlation between disp and mpg */
proc sgplot data = dshw;
scatter x = disp y= mpg/ group=vs markerattrs=(size=10px);
styleattrs
  datasymbols = (circle square);
run;
/*canonical*/
proc cancorr data = dshw all vprefix = response wprefix = measure;
var mpg disp;
with qsec hp drat wt;
run;


/*cluster*/
data clus;
set dshw;
id = _n_;
run;
proc cluster data=clus s standard method=average rmsstd rsquare outtree=tree;
var mpg disp hp drat wt qsec; 
ID id;
run;

proc tree data=tree out=treeout nclusters=2; 
copy mpg disp hp drat wt qsec;
ID id; 
run;

proc sort data = treeout;
by cluster;

proc print data = treeout;
var id cluster;
run;

proc means data = treeout;
var mpg disp hp drat wt qsec;
by cluster;
output out = means mean = mpg disp hp drat wt qsec;
run;


/*cluster+manova*/

data car_id;
set dshw;
id = _n_;
run; 

data clu_group;
set treeout;
keep id cluster;
run;

data car_clu;
merge car_id clu_group;
run;
proc print; run;

proc glm data = car_clu;
class cluster;
model  vs am gear carb cyl =  cluster;
manova h=cluster/ prinh printe;
/*model mpg disp =vs am gear carb cyl/ss3;*/
/*manova h= vs am gear carb cyl / prinh printe;*/
/*means vs am gear carb cyl;*/
run; 



/*Multiple regression*/
data multi;
set dshw;
keep mpg disp qsec hp drat wt am gear;
/*keep mpg qsec hp wt vs ;*/
run;
proc print data = multi(obs=5);
run;

/*Multi-reg original model*/
proc reg data= multi;
model mpg disp = qsec hp drat wt am gear;
mtest qsec=hp=drat=wt=am=gear=0 / printe;
mtest qsec = 0 / printe;
mtest hp = 0 / printe;
mtest drat = 0 / printe;
mtest wt = 0 / printe;
mtest am = 0 / printe;
mtest gear = 0 / printe;
run;

/*Multi-reg after backward*/
proc reg data= multi;
model mpg disp = qsec hp drat wt am gear /selection=backward;
mtest qsec=hp=drat=wt=am=gear=0 / printe;
mtest qsec = 0 / printe;
mtest hp = 0 / printe;
mtest drat = 0 / printe;
mtest wt = 0 / printe;
mtest am = 0 / printe;
mtest gear = 0 / printe;
run;

/*The final regression model of mpg*/
proc reg data= multi;
model mpg = qsec wt am;
mtest qsec=wt=am=0 / printe;
mtest qsec = 0 / printe;
mtest wt = 0 / printe;
mtest am = 0 / printe;
run;

/*The final regression model of disp*/
proc reg data= multi;
model disp = qsec hp wt gear;
mtest qsec=hp=wt=gear=0 / printe;
mtest qsec = 0 / printe;
mtest hp = 0 / printe;
mtest wt = 0 / printe;
mtest gear = 0 / printe;
run;

