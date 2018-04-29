 function rhocp = C_metal(T,Mtyp)

% Finds the volumetric heat capacity of metals.
% ______________________________________________

%	Copyright (C) 2018, Gary Clow

%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, version 3 of the License.

%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License v3.0 for more details.

%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

%	Developer can be contacted by,
%	email at:
%		gary.clow@colorado.edu
%	paper mail at:
%		Institute of Arctic and Alpine Research
%		University of Colorado
%		Campus Box 450
%		Boulder, CO 80309-0450 USA
% ______________________________________________

% Notation:

%   T     = temperature (C)             (vector)
%   Mtyp  = meterial type               (scalar)
%   rhocp = volumetric heat capacity    (vector)

% Available metals:

%   40  steel drill pipe
%   41  stainless steel
%   42  cast iron
%   43  aluminum
%   44  copper

% Notes:
%   (1) This routine does not currently take into account the temperature 
%       dependence.

% Source: internet tables
% ______________________________________________

 switch Mtyp(1)
 case 40            % steel drill pipe
   rho = 7833;
   cp  = 490;

 case 41            % stainless steel
   rho = 7982;
   cp  = 480;

 case 42            % cast iron
   rho = 7300;
   cp  = 460;

 case 43            % aluminum
   rho = 2705;
   cp  = 910;

 case 44            % copper
   rho = 8944;
   cp  = 390;

 end
 rhocp = rho*cp *ones(size(T));
