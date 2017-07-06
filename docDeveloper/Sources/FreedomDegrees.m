%% FreedomDegrees class
%
% <html>
% <h2>Introduction</h2>
% <p>FreedomDegrees class is an association of FreedomDegreeUnit classes,
% it containts all the methods in order to manage the whole association as
% unique entity.</p>
% <h2>FreedomDegrees class in Comp3d.Element</h2>
% <p>For example, it is clear that each Comp3d.Element has several freedom 
% degrees and that it is easier if the instruction related to each freedom
% degree are grouped.</p>
% <p>To define the freedom degrees of a Comp3d.Element a table must be
% loaded with all the information. The fields that each row must contain
% are the following.</p>
% <table>
% <tr>
%   <th>Name</th>
%   <th>lower bound</th>
%   <th>starting point</th>
%   <th>upper bound</th>
%   <th>status</th>
%   <th>relation</th>
% </tr></table>
% <p></p>
% <p>Once the table has been defined it is loaded into the freedomDegrees
% class using the following instruction:
% <i>obj.createFreedomDegreesFromTable(object,table)</i> where "object" is
% the comp3d object to whom all the freedom degrees are related and table
% is the description table of the freedom degrees.</p>
% <p>For example, let us consider the implementation in
% Comp3d.InductorCustomEI. The freedom degrees are defined as follows:</p>
% </html>
  freedomDegreesTable = [ ...
                {'legWidth'},             {'meter'},    5e-3,  10e-3,   1e-1,   'free',     {[]}; ... % legWidth (m)
                {'legThickness'},         {'meter'},   10e-3,  20e-3,   1e-1,   'free',     {[]}; ... % legThickness (m)
                {'airGap'},               {'meter'},    1e-6, 0.3e-3,   3e-3,   'free',     {[]}; ... % airGap (m)
                {'windingCoreDistance'},  {'meter'},    1e-4, 0.6e-3,   1e-2,   'setToX0',  {[]}; ... % windingCoreDistance (m)
                {'interTurnSpace'},       {'meter'},    5e-5, 0.1e-3,   2e-4,   'setToX0',  {[]}; ... % interTurnSpace (m)
                {'nTurns'},               {'turn'},        2,      8,     40,   'free',     {[]};  ... % number of Turns (n)
                {'conductorWidth'},       {'meter'},  0.1e-3,	1e-3,  2e-3,   	'free',     {[]}; ... % conductorWidth (m)
                {'conductorHeight'},      {'meter'},    7e-3,  30e-3, 60e-3,    'free',     {[]}; ... % conductorHeight (m)
                ];
 %% 
 % <html>
 % <p>Then they are loaded into the component with the following command
 % <i>obj.freedomDegrees_.createFreedomDegreesFromTable( obj,
 % freedomDegrees);</i> where obj.freedomDegrees_ is by default a
 % Comp3d.FreedomDegreesClass</p>
 % <h2>FreedomDegreesClass in Comp3d.Composite</h2>
 % <p>A Comp3d.Composite is an association of a Comp3d.Elements and
 % therefore the freedomDegrees of a Comp3d.Composite can be considered as
 % the association of the freedomDegrees of each Comp3d.Element. This
 % association is merely an association of the freedomDegreesUnit classes
 % and we are creating a sort of pointer at each encapsulation of the
 % material</p>
 % <p>This property is particularly interesting for the optimization as we
 % are creating a sort of "link" or "path" between the mathematical problem
 % and the objects themselves</p>
 % <p>The association and dissociation of the freedomDegrees is hidden for
 % the normal user as it is implied in the method <i>addComp3d</i> of the 
 % Comp3d.Composite class. The specific methods to perform these operations
 % are <i>attachFreedomDegrees</i> and <i>detachFreedomDegrees</i>.</p>
 % <h2>Changing the freedom degrees</h2>
 % <h2>Loading and saving the freedom degrees</h2>
 % <p>The configuration of the freedom degrees can be saved to a .txt and
 % afterwards loaded. The instruction to save the freedom degree
 % configuration is performed through the method
 % <i>saveFreedomDegrees</i>.</p>
 % </html>
            