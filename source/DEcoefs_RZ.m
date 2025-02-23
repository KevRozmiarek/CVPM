 function [aU,aUp,aD,aDp,aW,aWp,aE,aEp,aP,aPp,b] ...
    = DEcoefs_RZ(dt,f,rf,lambda,Dz,Ar,Az,VP,C,KeR,KeZ,QS,BCtypes,q,qn)

% Finds the discretization coefficients for the 2-D cylindrical CVPM model.
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

% Inner boundary condition is set by,

%   innerBC_type:   'T'     prescribed temperature
%                   'q'     prescribed heat flux
%                   'none'  there is no inner boundary

% Outer boundary condition is set by,

%   outerBC_type:	'T' prescribed temperature
%                   'q' prescribed heat flux

% Lower boundary condition is set by,

%   lowerBC_type:	'T' prescribed temperature
%                   'q' prescribed heat flux

% Notation:

%   dt                      time step                           (scalar)
%   f                       implicit/explicit factor            (scalar)
%   rf                      radial CV interfaces                (N+1)
%   lambda                  a radial factor                     (N+1)
%   Dz                      vertical CV width                   (M+1)
%   Ar                      rf*Dz/dr                            (M+1,N+1)
%   Az                      lambda/dz                           (M+1,N+1)
%   VP                      lambda*Dz                           (M+1,N+1)
%   C                       volumetric heat capacity            (M+1,N+1)
%   KeR                     effective conduct., R-interfaces    (M+1,N+1)                               (M+1,N+1)
%   KeZ                     effective conduct., Z-interfaces    (M+1,N+1)
%   QS                      spatially integrated source term    (M+1,N+1)
%   BCtypes                 inner/outer/upper/lower BC types    (strings)
%   q                       heat fluxes, this time step         (4)
%   qn                      heat fluxes, last time step         (4)
%   aW,aWp,aE,aEp,aU,aUp,   DE coefficients                     (M,N)
%   aD,aDp,aP,aPp,b          "      "                           (M,N)
%   j                       radial index
%   k                       vertical index

% Notes:

%   The source term is assumed to be independent of r.
% ______________________________________________

 M = size(C,1) - 1;
 N = size(C,2) - 1;

% pre-allocate arrays

 aU  = zeros(M+1,N+1);
 aUp = zeros(M+1,N+1);
 aD  = zeros(M+1,N+1);
 aDp = zeros(M+1,N+1);
 aW  = zeros(M+1,N+1);
 aWp = zeros(M+1,N+1);
 aE  = zeros(M+1,N+1);
 aEp = zeros(M+1,N+1);
 b   = zeros(M+1,N+1);

% unpack BCs

 upperBC_type = BCtypes{1};
 lowerBC_type = BCtypes{2};
 innerBC_type = BCtypes{3};
 outerBC_type = BCtypes{4};

 switch upperBC_type
 case 'q'
   qs  = q{ 1};
   qsn = qn{1};
 end
 switch lowerBC_type
 case 'q'
   qb  = q{ 2};
   qbn = qn{2};
 end

 switch innerBC_type
 case 'q'
   qa  = q{ 3};
   qan = qn{3};
 end
 switch outerBC_type
 case 'q'
   qo  = q{ 4};
   qon = qn{4};
 end

% indices of inner/outer/upper/lower CVs

 kU = 2;        % upper CV
 kL = M;        % lower CV

 switch innerBC_type
 case {'T','q'}
   jI = 2;      % inner CV
 case 'none'
   jI = 1;
 end
 jO = N;        % outer CV

% define the following for convenience

 g           = 4/3;
 dtf         = dt * f;
 dt1mf       = dt * (1-f);

 lambdadtf   = lambda * dtf;
 lambdadt1mf = lambda * dt1mf;
 Dzdtf       = Dz * dtf;
 Dzdt1mf     = Dz * dt1mf;

 VPC         = VP .* C;
 AKeR        = Ar .* KeR;
 AKeZ        = Az .* KeZ;

% coefficients aU,aUp,aD,aDp

 for k=kU:kL
   aU( k,:) = dtf   .* AKeZ(k  ,:);
   aUp(k,:) = dt1mf .* AKeZ(k  ,:);
   aD( k,:) = dtf   .* AKeZ(k+1,:);
   aDp(k,:) = dt1mf .* AKeZ(k+1,:);
 end

 k = kU;
 switch upperBC_type
 case 'T'
   aU( k,:) = g * aU( k,:);
   aUp(k,:) = g * aUp(k,:);
   aD( k,:) = g * aD( k,:);
   aDp(k,:) = g * aDp(k,:);
 case 'q'
   aU( k,:) = 0;
   aUp(k,:) = 0;
 end

 k = kL;
 switch lowerBC_type
 case 'T'
   aU( k,:) = g * aU( k,:);
   aUp(k,:) = g * aUp(k,:);
   aD( k,:) = g * aD( k,:);
   aDp(k,:) = g * aDp(k,:);
 case 'q'
   aD( k,:) = 0;
   aDp(k,:) = 0;
 end

% coefficients aW,aWp,aE,aEp

 for j=jI:jO
   aW( :,j) = dtf   .* AKeR(:,j);
   aWp(:,j) = dt1mf .* AKeR(:,j);
   aE( :,j) = dtf   .* AKeR(:,j+1);
   aEp(:,j) = dt1mf .* AKeR(:,j+1);
 end

 j = jI;
 switch innerBC_type
 case 'T'
   aW( :,j) = g * aW( :,j);
   aWp(:,j) = g * aWp(:,j);
   aE( :,j) = g * aE( :,j);
   aEp(:,j) = g * aEp(:,j);
 case {'q','none'}
   aW( :,j) = 0;
   aWp(:,j) = 0;
 end

 j = jO;
 switch outerBC_type
 case 'T'
   aW( :,j) = g * aW( :,j);
   aWp(:,j) = g * aWp(:,j);
   aE( :,j) = g * aE( :,j);
   aEp(:,j) = g * aEp(:,j);
 case 'q'
   aE( :,j) = 0;
   aEp(:,j) = 0;
 end

% coefficients aP and aPp

 aP  = VPC + (aU  + aD  + aW  + aE);
 aPp = VPC - (aUp + aDp + aWp + aEp);

% coefficient b

 b = dt * repmat(lambda,[M+1 1]) .* QS;

 switch upperBC_type
 case 'q'
   k = kU;
   b(k,:) = b(k,:) + (lambdadtf .*qs + lambdadt1mf .*qsn);
 end
 switch lowerBC_type
 case 'q'
   k = kL;
   b(k,:) = b(k,:) - (lambdadtf .*qb + lambdadt1mf .*qbn);
 end

 switch innerBC_type
 case 'q'
   j = jI;
   b(:,j) = b(:,j) + (Dzdtf *rf(j).*qa + Dzdt1mf *rf(j).*qan);
 end
 switch outerBC_type
 case 'q'
   j = jO;
   b(:,j) = b(:,j) - (Dzdtf *rf(j+1).*qo + Dzdt1mf *rf(j+1).*qon);
 end

% discard unused portion of arrays

 aU  = aU( 1:M,1:N);
 aUp = aUp(1:M,1:N);
 aD  = aD( 1:M,1:N);
 aDp = aDp(1:M,1:N);
 aW  = aW( 1:M,1:N);
 aWp = aWp(1:M,1:N);
 aE  = aE( 1:M,1:N);
 aEp = aEp(1:M,1:N);
 aP  = aP( 1:M,1:N);
 aPp = aPp(1:M,1:N);
 b   = b(  1:M,1:N);
