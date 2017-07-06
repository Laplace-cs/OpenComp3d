%% Freedom Degrees Comp3d
% <html>
% <p>In the OpenComp3d optimization framework, the optimization variables
% are the physical dimensions of the different components. However, the
% user can choose among all the different dimensions for the optimization
% to choose. </p>
% <h2>Freedom degrees usage</h2>
% <p> The freedom degrees of each component are stored under the property
% <i>freedomDegrees</i>, for example:<p>
% </html>
myInd = Comp3d.InductorCustomEI;
myInd.freedomDegrees.writeText;

%%
% <html>
% <p>As shown, the freedom degrees have different parameters:</p>
% <ul>
%   <li>nameFiels: name of the fields</li>
%   <li>lB: Lower bound of each freedom degree</li>
%   <li>x0: Starting point for the optimization</li>
%   <li>uB: Upper bound of each freedom degree</li>
%   <li>unit: unit of the freedom degree</li>
%   <li>status: this field can take three different values
%           <ul>
%               <li>free: the parameter is taken into account in the
%               optimization problem and will vary between lB and uB.</li>
%               <li>setToX0: the parameter is fixed at an specific value
%               and will not change during the optimization.</li>
%               <li>homotetic: the variable is proportional to other
%               optimization variable. The relationship is stated in the
%               field "width".</li>
%           </ul></li>
%   <li>with: specifies the relationship between the variables when the
%   status parameter is set to "homothetic"</li>
% </ul>
% <p>To change one of these parameters use the command setField. Ex: let us
% modify the x0 field of legWidth to 0.02 and the fix the value of the
% airgap.</p>
% </html>
myInd.freedomDegrees.setField('name','legWidth','x0',0.02);
myInd.freedomDegrees.setField('name','airGap','status','setToX0');
myInd.freedomDegrees.writeText;

%%
% <html>
% <p><b>IMPORTANT:</b> the dimensions of the component and the x0 starting
% point are not linked, that is, their values can be different</p>
% <table>
% <tr><td>
% </html>
myInd.dimensions
%%
% <html>
% </td><td>
% </html>
myInd.freedomDegrees.writeText;
%%
% <html>
% </td></tr></table>
% <br></br>
% <p>In this example the value of the dimension legWidth(0.01) is different 
% from the x0 value of legWidth(0.02). If the user wants to set the current
% dimensions of the component as the x0 point for the optimization he must use
% the method <i>setPointAsInitialOpti</i>. Ex.</p>
% </html>
myInd.setPointAsInitialOpti;
%%
% <html>
% <table><tr><td>
% </html>
myInd.dimensions
%%
% <html>
% </td><td>
% </html>
myInd.freedomDegrees.writeText;
%%
% <html>
% </td></tr></table>
% <p>The x0 point has taken the values of the component dimensions (Ex:
% equal legWidth parameter</p>
% </html>

%%
% <html>
% <h2>Setting the freedom degrees using an interface</h2>
% <p>The components have an integrated method to define the freedom degrees 
% using an interface. The command is <i>variable</i>.freeedomDegrees.GUI</p>
% </html>
myInd.freedomDegrees.GUI;
%%
% <html>
% <p>In this interface the user can manually define the optimization
% variables</p>
% </html>

%%
% <html>
% <h2>Save freedom degrees</h2>
% <p>A freedom degrees configuration can be stored for future use, the
% command to save the freedom degrees is <i>variable
% name</i>.freedomDegrees.saveText(<i>file name</i>).</p>
% </html>
myInd.freedomDegrees.setField('name','legWidth','x0',0.02);
myInd.freedomDegrees.setField('name','airGap','status','setToX0');
myInd.freedomDegrees.setField('name','legThickness','x0',0.001);
myInd.freedomDegrees.saveText('example.txt');

%%
% <html>
% <h2>Load freedom degrees</h2>
% <p>A freedom degrees configuration can be loaded into a component to
% launch the optimization. The instruction is <i>variable
% name</i>.freedomDegrees.loadText(<i>file name</i>)</p>
% </html>
myInd2 = Comp3d.InductorCustomEI;
myInd2.freedomDegrees.writeText;
%%
% <html>
% <p>If we load the file</p>
% </html>
myInd2.freedomDegrees.loadText('example.txt');
myInd2.freedomDegrees.writeText;
