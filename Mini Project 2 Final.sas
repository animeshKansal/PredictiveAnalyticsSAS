/*Importing the training data set*/
DATA train;
SET "C:\Users\Hanson\Documents\Hanson\College\UTD Spring 2018\Predicive Analaysis using SAS - BUAN 6337\Project 2\mobileadstraining.sas7bdat";
RUN;
PROC PRINT data=train(obs=20);
RUN;
/*or*/
DATA train;
SET mobileadstraining;
RUN;

/*Importing the testing data set*/
DATA test;
SET "C:\Users\Hanson\Documents\Hanson\College\UTD Spring 2018\Predicive Analaysis using SAS - BUAN 6337\Project 2\mobileadstest.sas7bdat";
RUN;
PROC PRINT data=test(obs=20);
RUN;
/*or*/
DATA test;
SET mobileadstest;
RUN;

/***********Looking for relationships between variables  and install through plots**********************************/
PROC FREQ data=train;
TABLES install;
RUN;
/*Display height*/
proc sgplot data=train;
 scatter X=device_height Y=install; 
 title 'Display Height and Installations';
 label device_height='Display Height (in pixels)' install='Installation'; 
run;
/*Display Width*/
proc sgplot data=train;
 scatter X=device_width Y=install; 
 title 'Display Width and Installations';
 label device_width='Display Width (in pixels)' install='Installation'; 
run;
/*Resolution*/
proc sgplot data=train;
 scatter X=resolution Y=install; 
 title 'Display Resolution and Installations';
 label resolution='Display Resolution (pixels per inch)' install='Installation'; 
run;
/*Volume*/
proc sgplot data=train;
 scatter X=device_volume Y=install; 
 title 'Device Volume and Installations';
 label device_volume='Device Volume' install='Installation'; 
run;



/*****Finding the installation rate for each variable class and merging with master dataset******************/
/*Publisher*/
PROC MEANS data=train;
CLASS publisher_id;
VAR install;
OUTPUT OUT=pubinstall MEAN=pubinst;
RUN;
/*Merge install rate by Publisher*/
PROC SORT data=train;
BY publisher_id;
RUN;
DATA merge1;
MERGE train pubinstall;
BY publisher_id;
RUN;

/*Device Make*/
PROC MEANS data=train;
CLASS device_make;
VAR install;
OUTPUT OUT=makeinstall MEAN=makeinst;
RUN;
/*Merge Install rate by Device Make*/
PROC SORT data=merge1;
BY device_make;
RUN;
DATA merge2;
MERGE merge1 makeinstall;
BY device_make;
RUN;

/*Device Operating System*/
PROC MEANS data=train;
CLASS device_os;
VAR install;
OUTPUT OUT=osinstall MEAN=osinst;
RUN;
/*Merge Install rate by Device Operating System*/
PROC SORT data=merge2;
BY device_os;
RUN;
DATA merge3;
MERGE merge2 osinstall;
BY device_os;
RUN;

/*Device Platform*/
PROC MEANS data=train;
CLASS device_platform;
VAR install;
OUTPUT OUT=platinstall MEAN=platinst;
RUN;
/*Wifi*/
PROC MEANS data=train;
CLASS wifi;
VAR install;
OUTPUT OUT=wifiinstall MEAN=wifiinst;
RUN;
/*print check to see if outputs are correct*/
PROC PRINT data=pubinstall;
RUN;
PROC PRINT data=makeinstall;
RUN;
PROC PRINT data=platinstall;
RUN;
PROC PRINT data=osinstall;
RUN;
PROC PRINT data=wifiinstall;
RUN;
/*print check of merges*/
PROC PRINT data=merge1(obs=20);
RUN;
PROC PRINT data=merge2(obs=20);
RUN;
PROC PRINT data=merge3(obs=20);
RUN;




/*Creating a new dataset where we drop rows with publisher_id, device_make, and device_os with 0 installs*******/
/*deleting the first row*/
DATA new;
SET merge3 (WHERE=(_TYPE_=1));
RUN;
/*deleting rows with publishers with no installs*/
DATA new1;
SET new (WHERE=(pubinst>0));
RUN;
/*deleting rows with device makes with no installs*/
DATA new2;
SET new1 (WHERE=(makeinst>0));
RUN;
/*deleting rows with device platforms with no installs*/
DATA new3;
SET new2 (WHERE=(osinst>0));
RUN;
/*Print check*/
PROC PRINT data=new(obs=20);
RUN;
PROC PRINT data=new1(obs=20);
RUN;
PROC PRINT data=new2(obs=20);
RUN;
PROC PRINT data=new3(obs=20);
RUN;
/*72426 rows left after initial data cleansing*/
/*12512 rows removed new install rate 0.955%*/



/*****************Creating categorical variables for volume and display mode****************/
/*Adding the variables to the adjusted training dataset*/
DATA newtrain;
SET new3;
DROP _TYPE_ _FREQ_ pubinst makeinst osinst;
LENGTH HeightxWidth $ 30;
LENGTH vol_range $ 30;
HeightxWidth = catx('x',device_height,device_width);
 IF device_volume <0.1 then vol_range = "0-0.1";
 IF device_volume>=0.1 and device_volume<0.2 THEN vol_range = "0.1-0.2";
 IF device_volume>=0.2 and device_volume<0.3 THEN vol_range = "0.2-0.3";
 IF device_volume>=0.3 and device_volume<0.4 THEN vol_range = "0.3-0.4";
 IF device_volume>=0.4 and device_volume<0.5 THEN vol_range = "0.4-0.5";
 IF device_volume>=0.5 and device_volume<0.6 THEN vol_range = "0.5-0.6";
 IF device_volume>=0.6 and device_volume<0.7 THEN vol_range = "0.6-0.7";
 IF device_volume>=0.7 and device_volume<0.8 THEN vol_range = "0.7-0.8";
 IF device_volume>=0.8 and device_volume<0.9 THEN vol_range = "0.8-0.9";
 IF device_volume>=0.9 and device_volume<1.0 THEN vol_range = "0.9-1.0";
 IF device_volume>=1.0 and device_volume<1.1 THEN vol_range = "1.0-1.1";
IF device_height>device_width then display_mode = 1;
IF device_height<device_width then display_mode = 0;
RUN;
PROC PRINT data = newtrain(obs=10);
RUN;
/*Adding new variables to test dataset*/
DATA newtest;
SET test;
DROP _TYPE_ _FREQ_ pubinst makeinst osinst;
LENGTH HeightxWidth $ 30;
LENGTH vol_range $ 30;
HeightxWidth = catx('x',device_height,device_width);
 IF device_volume <0.1 then vol_range = "0-0.1";
 IF device_volume>=0.1 and device_volume<0.2 THEN vol_range = "0.1-0.2";
 IF device_volume>=0.2 and device_volume<0.3 THEN vol_range = "0.2-0.3";
 IF device_volume>=0.3 and device_volume<0.4 THEN vol_range = "0.3-0.4";
 IF device_volume>=0.4 and device_volume<0.5 THEN vol_range = "0.4-0.5";
 IF device_volume>=0.5 and device_volume<0.6 THEN vol_range = "0.5-0.6";
 IF device_volume>=0.6 and device_volume<0.7 THEN vol_range = "0.6-0.7";
 IF device_volume>=0.7 and device_volume<0.8 THEN vol_range = "0.7-0.8";
 IF device_volume>=0.8 and device_volume<0.9 THEN vol_range = "0.8-0.9";
 IF device_volume>=0.9 and device_volume<1.0 THEN vol_range = "0.9-1.0";
 IF device_volume>=1.0 and device_volume<1.1 THEN vol_range = "1.0-1.1";
IF device_height>device_width then display_mode = 1;
IF device_height<device_width then display_mode = 0;
RUN;
PROC PRINT data = newtest(obs=10);
RUN;
/*Adding variables to original training dataset*/
DATA newtrain1;
SET train;
DROP _TYPE_ _FREQ_ pubinst makeinst osinst;
LENGTH HeightxWidth $ 30;
LENGTH vol_range $ 30;
HeightxWidth = catx('x',device_height,device_width);
 IF device_volume <0.1 then vol_range = "0-0.1";
 IF device_volume>=0.1 and device_volume<0.2 THEN vol_range = "0.1-0.2";
 IF device_volume>=0.2 and device_volume<0.3 THEN vol_range = "0.2-0.3";
 IF device_volume>=0.3 and device_volume<0.4 THEN vol_range = "0.3-0.4";
 IF device_volume>=0.4 and device_volume<0.5 THEN vol_range = "0.4-0.5";
 IF device_volume>=0.5 and device_volume<0.6 THEN vol_range = "0.5-0.6";
 IF device_volume>=0.6 and device_volume<0.7 THEN vol_range = "0.6-0.7";
 IF device_volume>=0.7 and device_volume<0.8 THEN vol_range = "0.7-0.8";
 IF device_volume>=0.8 and device_volume<0.9 THEN vol_range = "0.8-0.9";
 IF device_volume>=0.9 and device_volume<1.0 THEN vol_range = "0.9-1.0";
 IF device_volume>=1.0 and device_volume<1.1 THEN vol_range = "1.0-1.1";
IF device_height>device_width then display_mode = 1;
IF device_height<device_width then display_mode = 0;
RUN;
PROC PRINT data = newtrain(obs=10);
RUN;



/*************creating undersampled data and oversampled data***********************/
/*making undersampled data*/
data usd; /*usd = undersampled data*/
set newtrain; /*dataset created from previous steps*/
if install=1 or (install=0 and ranuni(72426)<1/105) then output;
run; /*1379 rows .50181 rate of install*/
/*making weighted undersampled data*/
data wusd;
set usd;
 w=0.00955/0.50181; if install=0 then w=(1-0.00955)/(1-0.50181);
run;
/*making oversampled data*/
data onlyInstalls;
    set newtrain(where=(install = 1));
  run;
data DuplicatedInstalls(drop=i);
   do i = 1 to 118;
      do j = 1 to n;
         set onlyInstalls nobs=n point=j;
         output;
         end;
      end;
   stop;
   run;
data osd; /*osd = oversampled data*/
set newtrain DuplicatedInstalls;
run;
/*Making weighted oversampled data*/
data wosd;
set osd;
w=0.00955/0.50181; if install=0 then w=(1-0.00955)/(1-0.50181);
run;



/*************creating undersampled data and oversampled data with the original training set***********************/
/*making undersampled data*/
data underSampledData;
set newtrain1;
if install=1 or (install=0 and ranuni(84246)<1/120) then output;
run;
/*making weighted undersampled data*/
data weightedundersampleddata;
set underSampledData;
 w=0.008/0.49; if install=0 then w=(1-0.008)/(1-0.49);
run;
/*making oversampled data*/
data onlyInstalls;
    set newtrain1(where=(install = 1));
  run;
data DuplicatedInstalls(drop=i);
   do i = 1 to 118;
      do j = 1 to n;
         set onlyInstalls nobs=n point=j;
         output;
         end;
      end;
   stop;
   run;
data OverSampledDataSet;
set newtrain1 DuplicatedInstalls;
run;
/*Making weighted oversampled data*/
data weightedoversampleddata;
set OverSampledDataSet;
 w=0.008/0.49; if install=0 then w=(1-0.008)/(1-0.49);
run;




/*************Testing the model after data cleansing and sampling****************************/
/*SKIP TO THE LAST MODEL, FIRST 5 MODELS ARE JUST TESTING*/
/*model with original train dataset*/
proc logistic data=newtrain1;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume;
 score data=newtest out=test_logit_predict; /* predictions are made only for the dataset specified*/
run;
	/*ROC curve for test data*/
	proc logistic data=test_logit_predict plots=roc(id=prob);
	CLASS publisher_id device_make device_platform device_os display_mode publisher_id:device_make;
 	MODEL install (EVENT='1') =  resolution wifi device_volume/ nofit;
 	roc pred=p_1;
	run;
/*model with newtrain dataset*/
proc logistic data=newtrain;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume;
 score data=newtest out=test_logit_predict; /* predictions are made only for the dataset specified*/
run;
	/*ROC curve for test data*/
	proc logistic data=test_logit_predict plots=roc(id=prob);
	CLASS publisher_id device_make device_platform device_os display_mode publisher_id:device_make;
 	MODEL install (EVENT='1') =  resolution wifi device_volume/ nofit;
 	roc pred=p_1;
	run;
/*weighted UNDER-sampled data with original train dataset*/
proc logistic data=WeightedUnderSampledData;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume;
 weight w;
 score data=newtest out=test_logit_predict; /* predictions are made only for the dataset specified*/
run;
	/*ROC curve for test data*/
	proc logistic data=test_logit_predict plots=roc(id=prob);
	CLASS publisher_id device_make device_platform device_os display_mode publisher_id:device_make;
 	MODEL install (EVENT='1') =  resolution wifi device_volume/ nofit;
 	roc pred=p_1;
	run;
/*weighted OVER-sampled data with original train dataset*/
proc logistic data=WeightedOverSampledData;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume;
 weight w;
 score data=newtest out=test_logit_predict; /* predictions are made only for the dataset specified*/
run;
	/*ROC curve for test data*/
	proc logistic data=test_logit_predict plots=roc(id=prob);
	CLASS publisher_id device_make device_platform device_os display_mode publisher_id:device_make;
 	MODEL install (EVENT='1') =  resolution wifi device_volume/ nofit;
 	roc pred=p_1;
	run;
/*weighted over-sampled data with newtrain dataset*/
proc logistic data=wosd;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume;
 weight w;
 score data=newtest out=test_logit_predict; /* predictions are made only for the dataset specified*/
run;
	/*ROC curve for test data*/
	proc logistic data=test_logit_predict plots=roc(id=prob);
	CLASS publisher_id device_make device_platform device_os display_mode publisher_id:device_make;
 	MODEL install (EVENT='1') =  resolution wifi device_volume/ nofit;
 	roc pred=p_1;
	run;

/*FINAL MODEL weighted under-sampled data with newtrain dataset*/
proc logistic data=wusd;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume;
 weight w;
 score data=newtest out=test_logit_predict; /* predictions are made only for the dataset specified*/
run;
	/*ROC curve for test data*/
	proc logistic data=test_logit_predict plots=roc(id=prob);
	CLASS publisher_id device_make device_platform device_os display_mode publisher_id:device_make;
 	MODEL install (EVENT='1') =  resolution wifi device_volume/ nofit;
 	roc pred=p_1;
	run;





/***********************************************************PART 2*****************************************************************
/*ratio of 25:1*/
proc logistic data=newtrain1;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume / ctable pprob=(0.011);
run; /*creates a ratio of 20.7:1 C1:C2 errors*/
/*ratio of 50:1*/
proc logistic data=newtrain1;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume / ctable pprob=(0.0085);
run; /*creates a ratio of 39:1 C1:C2 errors*/
/*ratio of 100:1*/
proc logistic data=newtrain1;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume / ctable pprob=(0.008);
run; /*creates a ratio of 104:1 C1:C2 errors*/
/*ratio of 200:1*/
/*proc logistic data=newtrain1;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume / ctable pprob=(0.00788);
run; /*creates a ratio of 195.8:1 C1:C2 errors*/
proc logistic data=newtrain1;
CLASS publisher_id device_make device_platform device_os  display_mode publisher_id:device_make;
 logit: MODEL install (EVENT='1') =  resolution wifi device_volume / ctable pprob=(0.0079);
run; /*creates a ratio of 131:1 C1:C2 errors but reduces overall costs*/




/*exporting updated training dataset*/
PROC EXPORT data=newtrain OUTFILE="C:\Users\Hanson\Documents\Hanson\College\UTD Spring 2018\Predicive Analaysis using SAS - BUAN 6337\Project 2\dataexport.sas7bdat"
DBMS=DLM REPLACE;
RUN;


