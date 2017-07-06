function vec = logspace( xi, xf, n)
% vec = logspace( xi, xf, n)
% 
%   compute an logspace, but xi and xf are taken as in linspace
%
vec = logspace( log10(xi), log10(xf), n);
end
