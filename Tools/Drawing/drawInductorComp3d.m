function  drawInductor(x,y,l,ax,type,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if strcmp(type,'vertical')
grad = linspace(-pi/2,pi/2,100);
rad = l / 6;
xVal = rad * cos(grad);
yVal = rad * sin(grad);

for i = 1:3
    xPlot = x + xVal;
    yPlot = y - (2 * i - 1) * rad + yVal;
    drawLine(xPlot,yPlot,ax,varargin{1});
end


elseif strcmp(type,'horizontal')
   grad = linspace(0,pi,100);
   rad = l / 6;
   xVal = rad * cos(grad);
   yVal = rad * sin(grad);

for i = 1:3
    xPlot = x + (2 * i - 1) * rad+ xVal;
    yPlot = y  + yVal;
    drawLine(xPlot,yPlot,ax,varargin{1});
end 
    
end
end

