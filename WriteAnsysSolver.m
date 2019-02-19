function outs=WriteAnsysSolver(samplename,gelP,amsize,cellnode)
%%2018-08: Added PRNSOL_U output for reconstruction of displacement from ANYS
% Added PRNLD output to obtain traction force directly from reaction force
% on cell boundary
outs=[];
currentFolder = pwd;
filn=[samplename,'ASolve.txt'];
fid=fopen(filn,'w');
line1=['finish \n'];
fprintf(fid,line1);
line2=['/CWD, ', currentFolder];
fprintf(fid,'%s',line2);
line3=['\n','/clear \n','/TITLE,',samplename,'\n','/PREP7\n','/graph,full \n'];
fprintf(fid,line3);
line4=['block,0,',num2str(gelP.length),',0,',num2str(gelP.width),',0,',num2str(gelP.height),'\n'];
fprintf(fid,line4);
line5=['ET,1,SOLID185\n'];
fprintf(fid,line5);
%line3=['KEYOPT,1,2,0\n','KEYOPT,1,3,0\n','KEYOPT,1,6,0\n'];
%fprintf(fid,line3);
line6=['MPTEMP,,,,,,,, \n','MPTEMP,1,0 \n','MPDATA,EX,1,,',num2str(gelP.E),'\n','MPDATA,PRXY,1,,0.4\n'];
fprintf(fid,line6);
%line6=['AESIZE,ALL,',num2str(meshsize),'\n','MSHKEY,0\n','MSHAPE,1,3d \n','CM,_Y,VOLU \n','VSEL, , , ,\n','CM,_Y1,VOLU\n','CHKMSH,''VOLU''\n','CMSEL,S,_Y\n'];
line7=['ESIZE,',num2str(amsize),'\n nsel, all \n'];
fprintf(fid,line7);
line8=['vmesh,1 \n'];
fprintf(fid,line8);
line9=['*dim,Txy,table,',num2str(cellnode),',5,1\n'];
fprintf(fid,line9);
line10=['*tread,Txy,''',samplename,'load.txt''\n'];
fprintf(fid,line10);
line11=['*do,i,1,',num2str(cellnode),',1\n'];
fprintf(fid,line11);
line12=['d,Txy(i,1),ux,Txy(i,4)\n'];
fprintf(fid,line12);
line13=['d,Txy(i,1),uy,Txy(i,5)\n'];
fprintf(fid,line13);
line14=['*enddo\n'];
fprintf(fid,line14);
line15=['da,2,ux,0\n','da,2,uy,0\n','da,2,uz,0 \n'];
fprintf(fid,line15);
line='FINISH \n';
fprintf(fid,line);
line16=['/SOLU \n SOLVE \n FINISH \n /POST1 \n nsel,s,loc,z,0,0 \n /OUTPUT, PRNSOL_',samplename,',txt \n'];
fprintf(fid,line16);
line17=['PRNSOL,s,comp \n /OUTPUT \n'];
fprintf(fid,line17);
line18=['/OUTPUT, PRNSOL_U',samplename,',txt\n'];
fprintf(fid,line18);
line19=['PRNSOL,u,comp \n /OUTPUT \n'];
fprintf(fid,line19);
line20=['/OUTPUT, PRNLD_',samplename,',txt\n'];
fprintf(fid,line20);
line21=['prnld,F,0,all \n /OUTPUT \n FINISH \n'];
fprintf(fid,line21);
fclose(fid);
outs=filn;
end