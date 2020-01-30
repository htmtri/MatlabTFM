%% move the boundary created by input vertices by # of pixels indicated. Input: (boundary vertices,pixels)
%% Output: new boundary
function outp=moveBoundary(samp,varargin)
debug = 0;
switch nargin
    case 0 
        disp('Need a .mat file containting boundary vertices (named cellTrace)')
        return;
    case 1
        movParam = input('Enter the # of pixels to move:');
        if isempty(movParam)
            movParam = 20;
        elseif ~isnumeric(movParam)
           disp('Wrong input type, need an integer')
           return;
        end
    case 2
        movParam = varargin{1};
        if ~isnumeric(movParam)
           disp('Wrong input type, need an integer')
           return;
        end
    case 3
        movParam = varargin{1};
        if ~isnumeric(movParam)
           disp('Wrong input type, need an integer')
           return;
        end
        debug = varargin{2};
    otherwise
        disp('Wrong number of input')
        return;
end        

idata = load([samp,'.mat']);

Vertices = idata.cellTrace;
Lines=[(1:size(Vertices,1))' (2:size(Vertices,1)+1)']; Lines(end,2)=1;

k=LineCurvature2D(Vertices,Lines);
N=LineNormals2D(Vertices,Lines);
k(isnan(k)) = 0;
k(k<0) = 0;
k1=k*movParam;

moveX = Vertices(:,1)+k1.*N(:,1);
moveY = Vertices(:,2)+k1.*N(:,2);

if debug == 1
figure,  
hold on
plot([Vertices(:,1) Vertices(:,1)+k1.*N(:,1)]',[Vertices(:,2) Vertices(:,2)+k1.*N(:,2)]','g');
scatter(moveX, moveY,'k.')
% plot([Vertices(Lines(:,1),1) Vertices(Lines(:,2),1)]',[Vertices(Lines(:,1),2) Vertices(Lines(:,2),2)]','b');
plot(idata.cellTrace(:,1),idata.cellTrace(:,2),'r');
axis equal;
hold off
end

[inBoundary, onBoundary]= inpolygon(moveX,moveY,Vertices(:,1),Vertices(:,2));

if movParam > 0
    newX = moveX(~inBoundary&~onBoundary);
    newY = moveY(~inBoundary&~onBoundary);
elseif  movParam < 0
    newX = moveX(inBoundary&~onBoundary);
    newY = moveY(inBoundary&~onBoundary);
else
    x1 = idata.cellTrace(:,1);
    y1 = idata.cellTrace(:,2);
    assignin('base','xTraceOut',x1)
    assignin('base','yTraceOut',y1)
    outp.xTraceOut = x1;
    outp.yTraceOut = y1;
    return
end
% b = boundary(newX,newY,1);
order = 1;
windowsWidth = 11;
sgfx = sgolayfilt(newX,order,windowsWidth);
sgfy = sgolayfilt(newY,order,windowsWidth);
sgfx = rmmissing(sgfx);
sgfy = rmmissing(sgfy);

epsilon = 3.5;
rdp = RDP([sgfx, sgfy], epsilon);

tol = 0.01;
polyin = polyshape(rdp(:,1),rdp(:,2));
polyout = rmslivers(polyin,tol);
polyout = sortregions(polyout,'perimeter','descend');
R = regions(polyout);

if debug == 1
figure,  
hold on
scatter(moveX,moveY,'k.')
scatter(newX,newY,'b*')
plot(idata.cellTrace(:,1),idata.cellTrace(:,2),'r');
plot(R(1))
axis equal;
hold off
end

[x1,y1] = boundary(R(1));

if debug == 1
figure,  
hold on
plot(idata.cellTrace(:,1),idata.cellTrace(:,2),'r');
plot(x1,y1,'b')
axis equal;
hold off
end

assignin('base','xTraceOut',x1)
assignin('base','yTraceOut',y1)

outp.xTraceOut = x1; 
outp.yTraceOut = y1;
end