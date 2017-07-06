%% Blowing Air model documentation

%%
% <html>
% <p> The blowing air model correspond to a design case where the air speed
% at the input of the heatsink is fixed</p>
% <h2>Blowing Air inputs</h2>
% <ul>
%       <li><b>airSpeed</b> : speed of the air before going between the heatsink
%       fins [m/s]</li>
%       <li><b>temperature</b> : temperature of the air before entering the
%       heatsink [°C]</li>
% </ul>
% <h2>Example of utilization</h2>
% </html>
 air = Cooling.ForcedAir('airSpeed',4,'temperature',30);