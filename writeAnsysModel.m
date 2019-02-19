function outs=writeAnsysModel(samplename,gelP,amsize)
outs=[];
filn=[samplename,'model.txt'];
fid=fopen(filn,'w');
line1=['finish \n','/clear \n','/TITLE,',samplename,'\n','/PREP7\n','/graph,full \n'];
fprintf(fid,line1);
line5=['block,0,',num2str(gelP.length),',0,',num2str(gelP.width),',0,',num2str(gelP.height),'\n'];
fprintf(fid,line5);
line2=['ET,1,SOLID185\n'];
fprintf(fid,line2);
%line3=['KEYOPT,1,2,0\n','KEYOPT,1,3,0\n','KEYOPT,1,6,0\n'];
%fprintf(fid,line3);
line4=['MPTEMP,,,,,,,, \n','MPTEMP,1,0 \n','MPDATA,EX,1,,',num2str(gelP.E),'\n','MPDATA,PRXY,1,,0.4\n'];
fprintf(fid,line4);
%line6=['AESIZE,ALL,',num2str(meshsize),'\n','MSHKEY,0\n','MSHAPE,1,3d \n','CM,_Y,VOLU \n','VSEL, , , ,\n','CM,_Y1,VOLU\n','CHKMSH,''VOLU''\n','CMSEL,S,_Y\n'];
line6=['ESIZE,',num2str(amsize),'\n'];
fprintf(fid,line6);
%line7=['MSHAPE,0,3d \n','MSHKEY,1\n','VMESH,_Y1\n','MSHKEY,0\n'];
line7=['vmesh,1 \n nsel,s,loc,z,0,0 \n'];
fprintf(fid,line7);
line8=['/OUTPUT,NLIST_',samplename,',txt \n nlist \n /OUTPUT \n FINISH'];
fprintf(fid,line8);
fclose(fid);
outs=filn;
end