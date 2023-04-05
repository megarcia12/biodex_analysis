% M3 Lab
% biodexComparison.m
% Created 21 November 2022
% Mario Garcia | nfq3bd@virginia.edu

close all; clear; clc;

%% Loading Data
pathName = uigetdir('.mat') ; % Select folder containing data
filePattern = fullfile(pathName,'*.mat') ;
matFiles = dir(filePattern) ; % Finds mat files that will be imported
for i = 1:length(matFiles) % Determines how many files will be imported
    baseFileName = matFiles(i).name ;
    fullFileName = fullfile(pathName, baseFileName) ;
    matdata = load(fullFileName) ;
    tempName = matdata.csub ;
    bd.(tempName) = matdata.deMVC ;
    clear matdata
end
clear baseFileName filePattern fullFileName i matFiles pathName tempName

