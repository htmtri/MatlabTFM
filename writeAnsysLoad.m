function writeAnsysLoad(samplename,cellnode)
filn=['AnsysLoad',samplename,'.txt'];
fid=fopen(filn,'w');
line1=['*dim,Txy,table,',num2str(cellnode),',5,1\n'];
fprintf(fid,line1);
line2=['*tread,Txy,''',samplename,'load.txt''\n'];
fprintf(fid,line2);
line3=['*do,i,1,',num2str(cellnode),',1\n'];
fprintf(fid,line3);
line4=['d,Txy(i,1),ux,Txy(i,4)\n'];
fprintf(fid,line4);
line5=['d,Txy(i,1),uy,Txy(i,5)\n'];
fprintf(fid,line5);
line6=['*enddo\n'];
fprintf(fid,line6);
% line8=['*dim,loadf,table,',num2str(size(index_outcell,1)),',5,1\n'];
% fprintf(fid,line8);
% line9=['*tread,Txy,''',Dishn,posn,'nulf.txt''\n'];
% fprintf(fid,line9);
% line10=['*do,j,1,',num2str(size(index_outcell,1)),',1\n'];
% fprintf(fid,line10);
% line11=['f,loadf(j,1),fx,0\n','f,loadf(j,1),fy,0\n','f,loadf(j,1),fz,0\n','*enddo\n'];
% fprintf(fid,line11);
line12=['da,2,ux,0\n','da,2,uy,0\n','da,2,uz,0'];
fprintf(fid,line12);
fclose(fid);
end