 function rhocp = C_ice(T)

% Finds the volumetric heat capacity of water ice (Ih).
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

%   T     = temperature (C)                     (vector)
%   rhocp = volumetric heat capacity            (vector)

%   Tr    = reduced temperature (Tk/273.15)
%   Tk    = temperature (K)
% ______________________________________________

% parameters

 T0   = 273.15;
 a1   = 2096.1;
 a2   = 1943.8;
 rhoi = 917;

% Tr - 1

 Trm1 = T / T0;

% find the specific heat

 cp = a1 + a2 * Trm1;

% find the volumetric heat capacity

 rhocp    = rhoi * cp;
 L        = T > 0;
 rhocp(L) = 0;
