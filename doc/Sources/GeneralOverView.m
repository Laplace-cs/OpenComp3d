%% General Overview of OpenComp3d
% <html>
% <!-- -->
% <!-- -->
% <h2>Introduction</h2>
% <p>OpenComp3d is a framework to help  in the design of power electronics 
% equipment</p>. 
% <!-- -->
% <!-- -->
% <h2>Direct Modelling approach</h2>
% <p>In the direct modelling approach all the components the inputs of all the
% component models are:</p>
% <ul>
%   <li>Dimensions</li>
%   <li>Materials</li>
%   <li>Shape</li>
% </ul> 
% <p>From these inputs the different <b>properties</b>: <i>mass</i>, <i>volume</i>, <i>cost</i>... 
% can be calculated. In addition, the equivalent <i>electric</i>, <i>magnetic</i>,
% <i>thermal</i>... model of each component is extracted.
% <p>Moreover, if the different excitations the component is withstanding
% (<i>electrical</i>,<i>thermal</i>...) are inserted a set of extra <b>data</b> is 
% calculated. A schematic of the principle is given in is shown in the 
% following figure.
% <br></br>
%   <img src="../Sources/Images/Object.png" alt="Object Icon"
%   style="width:70%;display:block;margin:auto";" </img>
%   <a  href="CreateComp3dElement.html"> How to create a component </a>
% <!-- -->
% <!-- -->
% <h2>Excitations setting</h2>
% <p>To set the excitations two different methods are possible:</p>
% <ul>
% <li><b>Analytical</b> : in some cases the user knows easily the waveforms of each
%               component under certain hypothesis and conditions</li>
% <li><b>Simulation</b> : the framework posseses as well a solver where the
%                different component simulation models can be 
%                interconnected and the different waveforms calculated</li>
%  </ul>
%   <a  href="SetExcitations.html"> How to insert excitations </a>
%   <br></br>
% <!-- -->
% <!-- -->
% <h2>Output data calculation</h2>
% <p>As shown in the figure above once the inputs of the object are determined
% and the excitations inserted we can determine some extra data
% (temperature, losses...).</p>
% <a  href="ComputeOutputDataComp3d.html"> How to calculate output data</a>
% <br></br>
% </html>