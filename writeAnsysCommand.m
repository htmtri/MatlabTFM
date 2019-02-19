function out=writeAnsysCommand(samplename,homedrive,version,cores)
filn=[samplename,'ASolver_CMD.bat'];
fid=fopen(filn,'w');
line1=['@echo off \n'];
fprintf(fid,line1);
line2=['echo Ansys solving for stress \n']; 
fprintf(fid,line2);
line3=['set STARTTIME=%TIME%'];
fprintf(fid,'%s',line3);
line4=['\n']; 
fprintf(fid,line4);
line5=['start /WAIT "" ', '"' ,homedrive,':\Program Files\ANSYS Inc\v', num2str(version),'\ansys\bin\winx64\ANSYS',num2str(version),'.exe" -np ',num2str(cores),' -b -i ',samplename,'ASolve.txt', ' -o ',samplename,'SolverLog.txt'];
fprintf(fid,'%s',line5);
fprintf(fid,line4);
line6=['set ENDTIME=%TIME%'];
fprintf(fid,'%s',line6);
fprintf(fid,line4);
line7=['echo Start: %STARTTIME%'];
fprintf(fid,'%s',line7);
fprintf(fid,line4);
line8=['echo Finish: %ENDTIME%'];
fprintf(fid,'%s',line8);
fprintf(fid,line4);
line9=['exit'];
fprintf(fid,line9);
fclose(fid);
out=filn;
end