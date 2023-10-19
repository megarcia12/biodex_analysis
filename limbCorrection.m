% M3 Lab
% limbCorrection.m
% Created 9 June 2023
% Mario Garcia | nfq3bd@virginia.edu

%% File Location
KeyPath = ('C:\Users\nfq3bd\Box\R01 Sex Specific Modeling\03_Data'); % Input path were files are located
addpath(KeyPath);
demo = 'subject_anthropometry.xlsx'; % File containing demographic data to be imported

%% File Import
[~,~,demoRaw] = xlsread(demo); % Reads in excel file 

%% Limb Mass
limbRaw = cell2mat(demoRaw(3:end,26:end))';
idxToRemoveLimb = flip([3, 5, 12, 21]);
limbRaw(:, idxToRemoveLimb) = [];

% Ankle Correction
aLimb = limbRaw(2,:)./cosd(limbRaw(1,:)); aLimb(isinf(aLimb)|isnan(aLimb)) = 0; % Because we are using vert for 0 need to use cos
limbTor.ADP(1,:) = aLimb*sind(0); limbTor.ADP(2,:) = aLimb*sind(15);
limbTor.ADP(3,:) = aLimb*sind(30); limbTor.ADP(4,:) = aLimb*sind(45);
% Hip Ab/duction Correction
hdbLimb = limbRaw(4,:)./cosd(limbRaw(3,:)); hdbLimb(isinf(hdbLimb)|isnan(hdbLimb)) = 0; % Because we are using vert for 0 need to use cos
limbTor.HBD(1,:) = hdbLimb*sind(0); limbTor.HBD(2,:) = hdbLimb*sind(10);
limbTor.HBD(3,:) = hdbLimb*sind(20);
% Hip Ex/Flexion Correction
hefLimb = limbRaw(6,:)./cosd(limbRaw(5,:)); hefLimb(isinf(hefLimb)|isnan(hefLimb)) = 0; % Because we are using vert for 0 need to use cos
limbTor.HEF(1,:) = hefLimb*sind(0); limbTor.HEF(2,:) = hefLimb*sind(15);
limbTor.HEF(3,:) = hefLimb*sind(30);
% Knee Correction
kLimb = limbRaw(8,:)./sind(limbRaw(7,:)); kLimb(isinf(kLimb)|isnan(kLimb)) = 0; % Because we are using horz for 0 need to use sin
limbTor.KEF(1,:) = kLimb*sind(15); limbTor.KEF(2,:) = kLimb*sind(40);
limbTor.KEF(3,:) = kLimb*sind(65); limbTor.KEF(4,:) = kLimb*sind(90);

%% Variable Clearing
clear aLimb hdbLimb hefLimb kLimb anthro demo demoRaw idxToRemoveLimb idxToRemove KeyPath limbRaw