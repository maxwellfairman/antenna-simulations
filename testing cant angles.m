%% CubeCats 435 MHz Canted Turnstile - First-Pass Model
% Four-element canted turnstile
% Nominal cant angle: 45 degrees
% Frequency: 435 MHz
%
% IMPORTANT:
% This is an idealized four-dipole model for studying:
%   1. Cant angle
%   2. Radiation pattern
%   3. Polarization / axial ratio
%   4. Effect of 90-degree phase progression
%
% It does NOT yet include:
%   - CubeSat body
%   - Comms board
%   - Real tape-measure geometry
%   - Deployment mechanism
%   - Coax/feed network losses
%
% Those should be added after the basic geometry is understood.

clear;
clc;
close all;

%% =========================
%  USER PARAMETERS
% ==========================

% Operating frequency
f = 435e6;                 % Hz

% Speed of light
c = physconst('lightspeed');

% Wavelength
lambda = c/f;

% Nominal cant angle
cantAngle = 15;            % degrees

% Radius from spacecraft center to antenna feed points
% CHANGE THIS to match your CubeSat geometry.
radius = 0.1;            % meters

% Dipole length
% Approximately quarter wavelength as a starting point.
dipoleLength = lambda/4;

% Dipole width
dipoleWidth = 0.005;       % meters

% Phase progression around the four elements
phaseShift = [0 90 180 270];

%% =========================
%  DISPLAY BASIC PARAMETERS
% ==========================

fprintf('435 MHz Canted Turnstile Model\n');
fprintf('-------------------------------\n');
fprintf('Frequency:       %.1f MHz\n', f/1e6);
fprintf('Wavelength:      %.4f m\n', lambda);
fprintf('Dipole length:   %.4f m\n', dipoleLength);
fprintf('Cant angle:      %.1f degrees\n', cantAngle);
fprintf('Feed radius:     %.4f m\n', radius);
fprintf('\n');

%% =========================
%  CREATE ONE DIPOLE
% ==========================

% Create a dipole approximately resonant around 435 MHz.
element = dipole( ...
    Length=dipoleLength, ...
    Width=dipoleWidth);

%% =========================
%  FOUR ELEMENT POSITIONS
% ==========================

% Four equally spaced elements around the spacecraft.
%
% Element positions:
%
%       Element 1
%           |
%           |
%     4 ----+---- 2
%           |
%           |
%       Element 3

azimuth = [0 90 180 270];

x = radius*cosd(azimuth);
y = radius*sind(azimuth);
z = zeros(1,4);

elementPosition = [x' y' z'];

%% =========================
%  CALCULATE TILT AXES
% ==========================

% Each antenna starts pointing along +Z.
%
% We want each antenna to tilt:
%
%       upward
%          /
%         /
%        /
%       +--------> outward
%
% The rotation axis is tangent to the circle.
%
% For an element at azimuth phi:
%
% radial direction = [cos(phi), sin(phi), 0]
%
% tangent direction = [-sin(phi), cos(phi), 0]
numAngles = 6;
for i = 0:numAngles
    cantAngle = 90/numAngles * i;
    tiltAxis = zeros(4,3);
    
    for n = 1:4
    
        phi = azimuth(n);
    
        % Tangential axis
        tiltAxis(n,:) = [-sind(phi), cosd(phi), 0];
    
    end
    elements = cell(1, 4);
    for n = 1:4
        element = dipole(...
            Tilt = cantAngle,...
            TiltAxis = tiltAxis(n, :),...
            Length = dipoleLength,...
            Width = dipoleWidth, ...
            FeedOffset = -dipoleLength/2.1);
        elements{n} = element;
    end
    %% =========================
    %  CREATE CONFORMAL ARRAY
    % ==========================
    
    array = conformalArray( ...
        Element=elements, ...
        ElementPosition=elementPosition, ...
        Reference="origin", ...
        AmplitudeTaper=[1 1 1 1], ...
        PhaseShift=phaseShift);
    
    %% =========================
    %  SHOW ANTENNA GEOMETRY
    % ==========================
    
    figure;
    
    show(array);
    
    title(sprintf( ...
        '435 MHz Four-Element Canted Turnstile - %g° Cant', ...
        cantAngle));
    
    view(35,25);
    axis equal;
    
    %% =========================
    %  ARRAY LAYOUT
    % ==========================
    %{
    figure;
    
    layout(array);
    
    title('Canted Turnstile Element Layout');
    %}
    %% =========================
    %  RADIATION PATTERN
    % ==========================
    
    figure;
    
    pattern(array,f);
    
    ax = gca;
    title(ax, sprintf('Radiation Pattern - %g° Cant', cantAngle), ...
    'FontSize', 14, 'FontWeight', 'bold');
    %% =========================
    %  AXIAL RATIO
    % ==========================
    
    figure;
    
    axialRatio(array,f, 0, 0);
    
    title(sprintf( ...
        'Axial Ratio - %g° Cant', ...
        cantAngle));
    
    %% =========================
    %  AZIMUTH PATTERN
    % ==========================
    %{
    figure;
    
    patternAzimuth(array,f);
    
    title(sprintf( ...
        'Azimuth Pattern - %g° Cant', ...
        cantAngle));
    %}
    %% =========================
    %  ELEVATION PATTERN
    % ==========================
    
    figure;
    
    patternElevation(array,f);
    
    title(sprintf( ...
        'Elevation Pattern - %g° Cant', ...
        cantAngle));
    
    %% =========================
    %  IMPEDANCE
    % ==========================
    %{
    
    figure;
    
    impedance(array,f);
    
    title('Array Active Impedance at 435 MHz');
    
    %% =========================
    %  MESH
    % ==========================
    
    figure;
    
    mesh(array);
    
    title('Antenna Mesh');
    %}
end