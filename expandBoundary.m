%% Expand the boundary created by roipoly by input pixel. Input: (old boundary,pixel)
%% Output: new boundary
function outp=expandBoundary(varargin)
% load('Trace.mat');
if nargin ~= 2
    disp('Not enough argument')
    return
else
    cellTrace = varargin{1};
    px = varargin{2};
end

x = cellTrace(:,1);
y = cellTrace(:,2);
midx = round(mean(cellTrace(:,1)));
midy = round(mean(cellTrace(:,2)));
for i = (1:length(cellTrace(:,1)))
    if x(i) < midx
        x(i) = x(i)-px;
    elseif x(i) > midx
        x(i) = x(i)+px;
    end
    if y(i) < midy
        y(i) = y(i)-px;
    elseif y(i) > midy
        y(i) = y(i)+px;
    end
end

% figure(1)
% hold on
% plot(cellTrace(:,1),cellTrace(:,2),'r')
% plot(x,y,'k')
% hold off

newTrace(:,1) = x;
newTrace(:,2) = y;
outp = newTrace;
end