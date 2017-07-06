%% Creation of a Comp3d Component
% <html>
% In this example we will illustrate the main structure of the components
% under the OpenComp3d framework. To illustrate the class InductorCustomEI
% will be employed.
% <br></br>
% <b>IMPORTANT: All the variables/parameters ... are given in the
%   International System (SI) units.</b>
% <br></br>
% More information about the InductorCustomEI class can be found here
% (COMPLETER)
% <br></br>
% <h2> Component creation </h2>
% To create a class the syntax is the following
% <i>variable</i>= Comp3d. <i>name of the class</i>   Ex. 
% </html>
myInd = Comp3d.InductorCustomEI;

%% 
% <html>
% As it is shown the component posses by default a series of
% <i>properties</i>
% and <i>methods</i>. To show them type properties(<i> variable name </i>)
% </html>
properties(myInd)

%%
% <html>
% All the components in the library posses a series of properties that
% <b>ALL</b> the components must define. These are:
% </html>

%%
% <html>
%   <table>
%   <tr><th>Property</th><th>Description</th></tr>
%   <tr><td><i>name</i></td><td>Name of the object</td></tr>
%   <tr><td><i>dimensions</i></td> <td>Contains the different physical dimensions
%   that define the component</td></tr>
%   <tr><td><i>materials</i></td> <td>Constains the different properties from the materials
%   (conductor, magnetic, dielectric...)</td></tr>
%   <tr><td><i>shape</i></td> <td>Contains all the parameters relative to the
%    different models of the components (electric, thermal...)</td></tr>
%   <tr><td><i>modelParameters</i></td> <td>Contains all the parameters relative to the
%    different models of the components (electric, thermal...)</td></tr>
%   <tr><td><i>outputData</i></td> <td>Contains all the important data obtained from the
%    parameters of the components and the excitations. For example,
%    the temperature, losses...</td></tr>
%   </table>
% </html>


%%
% <html>
% All these properties have normally a default value, however this can be
% changed or defined at the begining.
% To know the different variables of the component we can refer to the
% document to do so type |help| <i>class of the object</i>. Ex:
% </html>
help Comp3d.InductorCustomEI

%%
% <html>
% In the help for example we can see that <i>legWidth</i> is an input of the
% model. To define this input at the creation of the component we type
% </html>
myInd = Comp3d.InductorCustomEI('legWidth',1.6e-2);

%%
% <html>
% To verify that the value has been declared we type
% </html>
myInd.dimensions

%%
% <html>
% As the user can see the value of the property <i>legWidth</i> was set to
% 0.016 and the rest are set to their default values. If the the user
% wants to update this value to 1e-2 for example he can type
% </html>
myInd.dimensions.legWidth = 1e-2;

%%
% <html>
% and then again see the values
% </html>
myInd.dimensions.legWidth

%%
% <html>
% The value was succesfully changed!!
% </html>

%% 
% <html>
% <h2>Component methods</h2>
% To show the methods of the component type |methods|(<i>variable name</i>)
% </html>
methods(myInd)

%% 
% <html>
% All the components in the library posses a series of methods for
% <b>ALL</b> the components. These are:
% </html>

%%
% <html>
%   <table>
%   <tr><th>Method</th><th>Description</th></tr>
%   <tr><td><i>displayInformation</i></td><td>Displays the different parameters of the component</td></tr>
%   <tr><td><i>drawComponent</i></td> <td>Draws the component in a 3D plot</td></tr>
%   <tr><td><i>computeModelParameters</i></td> <td>Computes the different parameters of the
%       models (electric,thermal...) of the component</td></tr>
%   <tr><td><i>setExcitations</i></td> <td>Sets the excitations of the components.  
%   More information about excitations can be found <a  href="SetExcitations.html"> here </a> </td></tr>
%   <tr><td><i>computeOutputData</i></td> <td>Computes the different output data (losses,
%   temperatures...) of the components. These requires that the excitations
%   were defined before</td></tr>
%   </table>
% </html>
%

%%
% <html>
% In the example:
% </html>
myInd.computeModelParameters;
myInd.displayInformation;

%%
myInd.drawComponent;

%%
% <html>
% </html>



