%% Parallel Beam Reconstruction Example
% Generate phantom, geometries, and produce a projection.
% Reconstruct assuming fbp, or something else?

% Phantom
x = phantom(128);

% Image geometry
nx = 128;
ny = 128;
dx = 1;
dy = 1;
offset_x = -.5;
offset_y = -.5;
mask = true(nx,ny);
ig = image_geom('nx',nx,'ny',ny, ...
    'dx',dx,'dy',dy, ...
    'offset_x',offset_x,'offset_y',offset_y, ...
    'mask',mask);

% Sinogram geometry
type = 'par';
orbit_start = 90;
orbit = 180;
nb = 185; % number of bins
na = 180; % number of angles
dr = 1; % ray spacing
%offset_r = -.5; % channel offset
offset_r = 0; % channel offset
strip_width = dr; % strip width
sgr = sino_geom(type,...
    'orbit_start',orbit_start,'orbit',orbit, ...
    'nb',nb,'na',na,'dr',dr, ...
    'offset_r',0,'strip_width',strip_width);

% Generate sinogram
table = {'square/strip','Ltab',[1000],'strip_width',[dr]};
nthread = jf('ncore');
Gr = Gtomo2_table(sgr,ig,table,'nthread',nthread);
rx = Gr*x;

im(rx);

geom = fbp2(sgr, ig);
xhat = fbp2(rx, geom);
