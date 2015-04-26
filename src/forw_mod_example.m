%% Test IRT Toolbox
%% - Generate phantoms
%% - Perform idealized forward model
%% - Display

close all;

cl = 0;
ch = 40;

dist = 200;

%% Phantom

% Phantom Generation

% Generate Head
x1 = phantom('Modified Shepp-Logan',128);
figure(1); imshow(x1); title('Modified Shepp-Logan Phantom');

% Generate Rect with Impulse
x2 = zeros(128);x2(40:70,50:80) = 1; x2(100,70) = 3;
figure(2); imshow(x2); title('Rectangular Phantom');

%x3 = zeros(128); x(5,64) = 1; x(100,70) = 2;

% %% MATLAB Radon Transform
% theta = 0:179;
% [yrm,xp] = radon(x,theta);
% figure; imagesc(yrm,[0 mx]); title('Parallel Beam Projection [Builtin]');
% xlabel('Rotation Angles [index]'); ylabel('Sensor Positions [index]'); 
% colormap(hot); axis image;
% 
% %% MATLAB Fanbeam Transform
% dist = 200;
% fan_geom = 'line';
% fan_spac = 1;
% fan_incr = 1;
% [yfm,fan_sensor_positions, fan_rotation_angles] = ...
%     fanbeam(x,dist, ...
%     'FanSensorGeometry',fan_geom, ...
%     'FanRotationIncrement',fan_incr, ...
%     'FanSensorSpacing',fan_spac);
% figure; imagesc(yfm,[0 mx]); title('Fan Beam Projection [Builtin]');
% xlabel('Rotation Angles [index]'); ylabel('Sensor Positions [index]'); 
% colormap(hot); axis image;

%% IRT Radon Transform

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

% Radon Transform 
table = {'square/strip','Ltab',[1000],'strip_width',[dr]};
nthread = jf('ncore');
Gp = Gtomo2_table(sgr,ig,table,'nthread',nthread);
px1 = Gp*x1;
px2 = Gp*x2;
figure(11); imagesc(px1); title('Parallel Beam of Head [IRT]');
xlabel('Rotation Angles [index]'); ylabel('Sensor Positions [index]'); 
colormap(hot); axis image;
figure(12); imagesc(px2); title('Parallel Beam of Rect [IRT]');
xlabel('Rotation Angles [index]'); ylabel('Sensor Positions [index]'); 
colormap(hot); axis image;

%% IRT Fanbeam Transform
orbit_start = 90;
orbit = 360;
type = 'fan';
nb = 187;
na = 360;
ds = 1; % ray spacing
offset_s = 0; % channel offset
strip_width = ds;
dso = dist; % distance from source to origin
dod = dist; % distance from origin to detector
dfs = Inf; % flat dector

sgf = sino_geom(type,...
    'orbit_start',orbit_start,'orbit',orbit, ...
    'nb',nb,'na',na,'ds',ds, ...
    'offset_s',offset_s,'strip_width',strip_width, ...
    'dso',dso,'dod',dod,'dfs',dfs);
    
% Fanbeam Transform 
table = {'linear','Ltab',[1000]};
%nthread = jf('ncore');
Gf = Gtomo2_table(sgf,ig,table);
fx1 = Gf*x1;
fx2 = Gf*x2;
figure(21); imagesc(fx1); title('Fan Beam of Head [IRT]');
xlabel('Rotation Angles [index]'); ylabel('Sensor Positions [index]'); 
colormap(hot); axis image;
figure(22); imagesc(fx2); title('Fan Beam of Rect [IRT]');
xlabel('Rotation Angles [index]'); ylabel('Sensor Positions [index]'); 
colormap(hot); axis image;


%% Comparison Plots

%% Radon / Parallel Beam
% 
% colr = 120;
% figure;
% plot(yrm(:,colr),'o-'); hold on; plot(yri(:,colr),'+-');
% title('Close Agreement between Parallel Beam Methods');
% legend('MATLAB Par Slice','IRT Par Slice');
% % Less agreement along edge - why? 
% % hypothesis:  slight angular offset, different forms of interpolation, irt's
% % strip width
% 
% %% Fan Beam
% 
% colf = 91;
% figure;
% plot(yfm(:,colf),'o-'); hold on; plot(yfi(:,colf),'+-');
% title('Title');
% legend('MATLAB Fan Slice','IRT Fan Slice');


%% Print
print(1,'-dpng','head-phantom.png')
print(2,'-dpng','rect-phantom.png');
print(11,'-dpng','head-para.png');
print(12,'-dpng','rect-para.png');
print(21,'-dpng','head-fan.png');
print(22,'-dpng','rect-fan.png');
%print(2,'-dpng','radon-proj-matlab.png')
%print(3,'-dpng','fanbeam-proj-matlab.png')
%print(4,'-dpng','radon-proj-irt.png');