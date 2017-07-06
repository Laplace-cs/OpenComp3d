%% Freedom degree unit class
% <html>
% <p>FreedomDegreeUnit is the basic class for the freedom degrees of a
% Comp3d.Component class. That is, each degree of freedom has it own
% separate FreedomDegreeUnit class.</p>
% <h2>FreedomDegreeUnit inputs</h2>
% <p>The class has a series of inputs that must be defined for each
% freedom degree</p>
% <table style="width:50%">
%   <tr>
%       <th>Name</th><th>Name of the freedom degree</th>
%   </tr><tr>
%       <th>Unit</th><th>Unit of the freedom degree</th>
%   </tr><tr>
%       <th>lB</th><th>Lower bound of the freedom degree for the
%       optimization</th>
%   </tr><tr>
%       <th>x0</th><th>Starting value in an optimization for the freedom
%       degree</th>
%   </tr><tr>
%       <th>uB</th><th>Upper bound of the freedom degree for the optimization</th>
%   </tr><tr>
%       <th>status</th><th>Defines the behaviour the freedom degree will
%       have during the optimization. It can take three different values:
%       <ul>
%           <li>free: the freedom degree is be an optimization variable
%           that can vary between the lower bound (lB) and upper
%           bound(uB)</li>
%           <li>setToX0: the freedom degree has a fixed value determined by
%           the x0 and will not change during the optimization.</li>
%           <li>homothetic: the freedom degree depends on other freedom
%           degrees and will vary between lB and uB but it is not an
%           optimization variable.</li>
%        </ul></th>
%   </tr><tr>
%      <th>relation</th><th>Defines the homothetic relation for the freedom
%      degree. IMPORTANT: the relation field must be defined in order to
%      set the status property to <i>"homothetic"</i>.</th>
%   </tr><tr>
%       <th>val</th><th>Defines the current actual value of the freedom
%       degree which can be different from the x0 freedom degree</th>
%   </tr>
%   </table>
%   <p></p>
%   <h2>How the homothetic relations works</h2>
%   <p>When the <i>"status"</i> property is set to <i>"homothetic"</i> the
%   freedom degree is dependent of another freedom degree which can be as
%   well dependent on another and so forth. As shown in the following figure.</p>
%   <p>To deal with this kind of behaviour three additional properties are
%   defined.</p>
%   <ul>
%       <li><b>objectRef</b>: defines the object where the freedom degree is
%       attached, that is which element contains this freedom degree and is
%       going to be impacted by the freedom degree class. For example, if
%       we are considering the number of turns of a certain inductor
%       object, the inductor object is our "objectRef".</li>
%       <li><b>relationObject</b>: defines the object from which the object is
%       dependent. It can be the same object, for example the length of a
%       baseplate can depend on the width of the baseplate (length = 2*
%       width) or it can depend on another different object. For example,
%       the lenght of the baseplate may depend on the length of the fins.
%       <b>IMPORTANT</b>: if the relationObject is different than
%       objectRef, some methods of freedom degrees might become
%       blocked.</li>
%       <li><b>freedomDegreeDepArray</b>: determines the freedomDegreeUnit classes
%       that are dependent on the freedomDegreeUnit and that will be called
%       each time the freedomDegree value changes</li>
%   </ul>
%   <img src="../Sources/Images/FreedomDegreeUnit.png" alt="Object Icon"
%   style="width:50%;display:block;margin:auto";" </img>
%   <p>For example, let us consider in a heatsink the length of the baseplate that
%   depends is the same as the length of the fins, and the width of the baseplate that
%   is defined as 2 times the length of the baseplate.The schematic will
%   rest as described by the following figure.</p>
%   <img src="../Sources/Images/FreedomDegreeUnitHeatSink.png" alt="Object Icon"
%   style="width:50%;display:block;margin:auto";" </img>
% <h2>How to link freedom degrees</h2>
% <p>By default, the relationObj is considered the same as the objectRef,
% that is, we consider the relationship is set between freedom degrees of
% the same component.</p>
% <p>However in some case the relation might be set between different
% components. The method to do so is called 
% <i>homotheticFreedomDeg.linkFreedomDegrees(homotheticFreedomDeg,objectToRelate)</i></p>
% <p>After this instruction, the freedom degrees remain as follows.</p>
%   <img src="../Sources/Images/FreedomDegreeLinkExample.png" alt="Object Icon"
%   style="width:90%;display:block;margin:auto";" </img>
% <p>Indeed, a link has been created between the freedom degrees, as a
% result, when the value of the free freedom degree changes the homothetic
% value is updated as well. The chain of relation is called sequentally and
% no loop can be established between objects</p>
%   <img src="../Sources/Images/FreedomDegreeChain.png" alt="Object Icon"
%   style="width:50%;display:block;margin:auto";" </img>
% </html>
%   