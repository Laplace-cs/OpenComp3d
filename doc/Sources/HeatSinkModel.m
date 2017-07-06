%% Heat Sink model
%

%%
% <html>
% <h2> General overview </h2>
% <p>To improve the cooling perfomances of a certain device, a heat sink is
% often. The main objective is to create a heat spreader and therefore
% "increase" the contact surface between the device to be cooled and the
% external fluid.</p>
% <p>In this model, the heat sink is considered the association of 4
% different elements:</p>
% <ul>
%   <li><b>Fins</b>: corresponds to the additional surfaces added to increase the
%   surface of the component to be cooled </li>
%   <li><b>Base Plate</b>: is the part in contact between the cooled surface and
%   the fins. Its surface however can be different from the cooled surface,
%   in that case, the spreading effect needs to be taken into account</li>
%   <li><b>Heating element</b>: is the element to be cooled</li>
%   <li><b>Blowing element</b>: is the element that determines the properties of
%   the fluid arriving and passing through the fins of the heat sink</li>
%   <img src="../Sources/Images/HeatSink.png" alt="HeatSink Icon"
%   style="width:50%"; display="block"; margin="auto"> </img>
% </ul>
% </html>

%% 
% <html>
% <h2>Heat Sink creation </h2>
% <p>In order to create the heat sink all the elements must be created and
% added to the heat sink model. The method to perform this operation is 
% <i>heatsinkElt</i>.addElement(<i>element name</i>).</p>
% <p><b>IMPORTANT:</b> for the blowing element, fins and base plate if the
% element type has been previously added, the new component will substitute the
% previous one.</p>
% <p>In addition, the heating elements can be removed as well using the
% following method <i>heatsinkElt</i>.removeElement(<i>element
% name</i>)</p>
% </html>

%%
% <html>
% <h2>Base Plate</h2>
% <p>The base plate is the element performing the mechanical association
% between the cooled surface and the fins. Its lower surface may differ
% from the surface to be cooled resulting in an additional "spreading 
% resistance". The list of different baseplates that can be used are:</p>
% <ul>
%   <li><a  href="BasePlateModel.html"> BasePlate</a> : a simple basic model of
%   baseplate</i>
% </ul>
% <h2>Fins</h2>
% <p>The fins are the additional surfaces to "increase" the cooled surface, 
% these fins cause as well friction losses when forced air circulates
% between them. The cooling and pressure losses performances depend on the
% shape of the fins. In this library the different shapes are:</p>
% <ul>
%   <li><a  href="RectangularFinsModel.html"> Rectangular Fins</a></li>
% </ul>
% <h2>Blowing Element</h2>
% <p>Since the model is described for forced convection we need an element
% that creates the movement of the air</p>
% <ul>
%     <li><a  href="DCFan.html"> FanDiscreteDC </a>: correspond to a fan used with a DC power supply</li>
%     <li><a  href="BlowingAir.html"> Forced Air </a>: correspond to a fixed imposed air speed</li>
% </ul>
% <h2>Surface to cool </h2>
% <p>The different element surfaces that can be cooled with the heatSink
% are:</p>
% <ul>
%   <li><a  href="HeatingSurface.html"> Heating Surface</a>: correspond to a surface
%        where we know the losses, the dimensions and the maximal temperature </li>
% </ul>
% <h2>Specific properites and methods </h2>
% <p>Apart from the usual <i>Comp3d.Composite</i> properties & methods some
% additional are included for this specific model</p>
% <p>Additional properties </p>
%   <ul>
%       <li><b>finElement</b>: property to point at the fin element</li>
%       <li><b>basePlate</b>: property to point at the base plate</li>
%       <li><b>blowingElement</b>: property to point at the blowing element</li>
%       <li><b>elementsToCool</b>: list of elements to be cooled</li>
%   </ul>
% <p> The specific methods of the <i>Comp3d.HeatSink</i> class are: </p>
%   <ul>
%       <li><b>displayPressureLossesCurve</b>: displays the pressure losses curve
%           of the heat sink, the operating point and if a fan is included the pressure
%           losses curve of the fan</li>
%   </ul>
% <h2>Example of utilization </h2>
% <p>For the example we will consider a heat sink with rectangular fins and
% where the air is forced at a certain speed to cool a 100x200 surface. The
% power is 50W and the 
% First, the elements are created:</p>
% </html>
myBasePlate = Comp3d.BasePlate('name','basePlate','level',2,'length',0.22,'width',0.12,'conductingMaterial',2);
myFins = Comp3d.RectangularFins('name','fins','level',2,'length',0.22,'numberOfFins',30,...
    'thickness',2e-3,'height',5e-2,'gapBetweenFins',2e-3,'conductingMaterial',2);
myBlowingElement = Cooling.ForcedAir('name','forcedAir','airSpeed',5,'temperature',25);
mySurface = Comp3d.HeatingSurface('name','heatingSurface','power',50,'length',0.2,'width',0.1,'tMax',125);

%%
% <html>
% <p>Then the composite is created, the elements are added to the heat sink and the parameters are
% computed </p>
% </html>
myHeatSink = Comp3d.HeatSink('name','heatSink');
myHeatSink.addElement(myBasePlate);
myHeatSink.addElement(myFins);
myHeatSink.addElement(myBlowingElement);
myHeatSink.addElement(mySurface);
myHeatSink.computeModelParameters;
myHeatSink.computeOutputData;
myHeatSink.displayInformation;
%%
% <html>
% <p>The drawing and the pressure losses curve can be as well displayed</p>
% </html>
myHeatSink.drawComponent;
myHeatSink.displayPressureLossesCurve;
