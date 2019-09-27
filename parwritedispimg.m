function parwritedispimg(samp,n,cimg,xgrid,ygrid,xdisp,ydisp,cellTrace)
    A = figure;
    imshow(cimg,[]);
    hold on,
    quiver(xgrid,ygrid,xdisp,ydisp,'c');
    plot(cellTrace(:,1),cellTrace(:,2),'r','LineWidth',2);
    hold off
    saveas(A,[samp,'-T',num2str(n),'disp'],'png');
end