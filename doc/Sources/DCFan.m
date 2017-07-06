%% FanDiscreteDC model documentation

%%
% <html>
% <p> FanDiscreteDC models a fan supplied with a DC supply and attached to a tube in order to connect the 
% different section areas of the heatsink and the fan</p>
% <h2>FanDiscreteDC inputs</h2>
% <ul>
%  <li><b>referenceFan</b> : reference of the fan (part number or id from the
%  database in DataBaseManager/ComponentManager/Fan/DCFan.xlsx)</li>
%  <li><b>widthOutTube</b> : width of the outer part of the tube [m]</li>
%   <li><b>heightOutTube</b> : height of the outer part of the tube [m]</li>
%   <li><b>lengthTube</b> : length of perpendicular axe of the tube [m]</li>
%   <li><b>thicknessFanTube</b> : thickness of the tube [m]</li>
%   <li><b>temperature</b> : temperature of the air before entering the heatsink [°C]</li>
%   <li><b>materialTube</b> : materialTube</li>
% </ul>
% <h2>Example of utilization</h2>
% </html>
 fan = Comp3d.FanDiscreteDC('referenceFan',1, 'widthOutTube',0.1, 'heightOutTube', 0.1, 'lengthTube',2e-2, 'thicknessFanTube',2e-3,...
     'temperature', 25, 'materialTube','Aluminium');