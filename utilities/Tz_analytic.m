 function T = Tz_analytic(experim,t,Ts0,Ts,qb,Z,Dz,dz,Kref,C,S0,hs)

% Analytic temperature solution (vertical dimension) for CVPM test cases.
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

% Currently available test cases:

%   Test1_*:  fixed BCs, zero source, homogeneous material
%   Test2_*:  composite material
%   Test3_*:  temperature-dependent material properties
%   Test4_*:  exponential heat source
%   Test5_*:  instantaneous step change on upper boundary
%   Test6_*:  linear increase in upper boundary temperatures
%   Test7_*:  periodic temperature on upper boundary
% ______________________________________________

 M  = length(Z) - 1;
 K  = Kref;             % default value for the bulk conductivity
 dT = Ts - Ts0;         % surface temperature change

 experim0 = experim(1:6);

 switch experim0
 case 'Test1_'

%  Steady-state, zero source.

%    T(z,0) = Ts + (-qb/K)*z
%    T(0,t) = Ts
%    S(z,t) = 0

   T = Ts0 + (-qb./K).*Z;

 case 'Test2_'

%  Same as Test1 but with a composite material.

%    T(z,0) = piecewise linear
%    T(0,t) = Ts
%    S(z,t) = 0

%    Find interface temperatures by integrating across CVs.  
%    Then interpolate to find CV grid point temperatures.

   T     = NaN*ones(size(Z));
   Tf    = NaN*ones(size(Z));
   T(1)  = Ts;
   Tf(1) = Ts;

   for k=1:M
     Tf(k+1) = Tf(k) - Dz(k)*qb/K(k);
   end

   for k=2:M
     T(k) = (Tf(k) + Tf(k+1))/2;
   end
   T(M+1) = Tf(M+1);

 case 'Test3_'

%  Same as Test1 but with temperature-dependent thermal conductivity

%    T(0,t) = Ts
%    S(z,t) = 0

% Find grid point temperatures by integrating between them.

   T    = NaN*ones(size(Z));
   T(1) = Ts0;
   Tr   = 0;          % reference temperature
   dKdT = -0.0125;    % dK/dT

   for k=2:M+1
     Kr   = Kref(k);
     a    = dKdT;
     b    = 2*(Kr - a*Tr);
     c    = -a*T(k-1)^2 - b*T(k-1) + 2*qb*dz(k);
     T(k) = (-b + sqrt(b^2 - 4*a*c)) / (2*a);
   end

 case 'Test4_'

%  Steady-state, exponential heat production.  Flux at any depth
%  is equal to the integral of the source S(z) below that depth.

%    T(z,0) = Ts + (-qb/K)*z - (S0*hs/K) * [exp(-zb/hs)*z + (exp(-z/hs)-1)*hs]
%    T(0,t) = Ts
%    S(z,t) = S0*exp(-z/hs)

   K  = K(1);
   S0 = S0(1);
   hs = hs(1);
   Zb = max(Z);
   T  = Ts0 + (-qb./K).*Z -(S0*hs/K) * (exp(-Zb/hs).*Z + (exp(-Z/hs)-1)*hs);

 case 'Test5_'

%  Instantaneous step change on upper boundary.

%    T(z,0) = Ts + (-qb/K)*z
%    T(0,t) = Ts + dT
%    S(z,t) = 0

   kappa = K ./ C;
   eta   = Z ./ sqrt(4*kappa*t);

   fac     = zeros(size(Z));
   L       = eta < 0.5;
   fac(L)  = 1 - erf(eta(L));
   LL      = ~L;
   fac(LL) = erfc(eta(LL));

   T = Ts0 + (-qb./K).*Z + dT*fac;

 case {'Test6_','Test6i'}

%  Surface temperature increases at a linear rate.

%   T(z,0) = Ts + (-qb/K)*z
%   T(0,t) = Ts + a*t
%   S(z,t) = 0

   a     = 1 /(86400*365*10);       % 1K/decade warming
   kappa = K ./ C;
   eta   = Z ./ sqrt(4*kappa*t);

   fac     = zeros(size(Z));
   L       = eta < 0.5;
   fac(L)  = 1 - erf(eta(L));
   LL      = ~L;
   fac(LL) = erfc(eta(LL));

   fac1 = (t + Z.^2 ./ (2*kappa)) .* fac;
   fac2 = Z .* sqrt(t./(pi*kappa)) .* exp(-eta.^2);
   fac3 = fac1 - fac2;

   T = Ts0 + (-qb./K).*Z + a*fac3;

 case 'Test7_'

%  Periodic surface temperature.

%    T(0,t)   = Ts + dT*cos(w*t)
%    T(inf,t) = Ts
%    S(z,t)   = 0

   secyr  = 86400*365;
   period =  1;             % 1 yr
   dT     =  1;             % amplitude
   Ts     = -10;            % mean surface temperature

   kappa  = K ./ C;
   lambda = secyr * period;
   w      = 2*pi/lambda;
   k      = sqrt(pi./(lambda*kappa));
   T      = Ts + dT*cos(k.*Z - w*t).*exp(-k.*Z);
 end
