 function [descript,IC,Imethod,Sc1,Sc2] = inputIC(ICfile,CS)

% Imports an initial temperature field.  
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

% Acceptable file types are:

%   (1) a comma delimited *.txt file (1-D simulations)
%   (2) a matlab *.mat file

% Notation:

%   ICfile   = initial-condition file name                  (character string)
%   CS       = coordinate system                            (character string)

%   descript = initial condition descriptor                 (character string)
%   IC       = initial temperatures at (H,Z)                (array)
%   Imethod  = method to be used when interpolating the IC  (character string)
%   Sc1      = values of 1st space coordinate returned      (vector)
%   Sc2      = values of 2nd space coordinate returned      (vector)

% Notes:

%   (1) For 1-D simulations, Sc2 is null.
% ______________________________________________

% determine the file type

 ext = findExt(ICfile);

% Extract information from file

 switch ext
 case 'mat'         % *.mat file ------------------------

   load(ICfile)

% assign space coordinates
   switch CS
   case 'R'
     Sc1 = R;
     Sc2 = [];
   case 'Z'
     Sc1 = Z;
     Sc2 = [];
   case 'RZ'
     Sc1 = R;
     Sc2 = Z;
   case 'XZ'
     Sc1 = X;
     Sc2 = Z;
   end

 case 'txt'         % text file -------------------------

   fid = fopen(ICfile,'r');

% read descriptors

   descript1 = fgetl(fid);
   descript2 = fgetl(fid);
               fgetl(fid);
   descript  = [descript1 '; ' descript2];

% interpolation method

   s = fgetl(fid); S = extract_strs(s); Imethod = S{1};

% read in IC, one time record (line) at a time

   A = [];
   while feof(fid) == 0
     s = fgetl(fid); x = extract_nums(s);
     A = [A; x];
   end
   n  = size(A,2);
   switch CS
   case {'R','X','Y','Z'}
     Sc1 = A(:,1);
     Sc2 = [];
   case {'RZ','XZ'}
     disp(' ')
     disp('inputIC: this case not implemented yet.')
     pause
   end
   IC = A(:,2:n);
 end
