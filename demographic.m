% M3 Lab
% demographic.m
% Created 9 June 2023
% Mario Garcia | nfq3bd@virginia.edu
close all; clear; clc;

%% File Location
KeyPath = ('C:\Users\nfq3bd\Box\R01 Sex Specific Modeling\03_Data'); % Input path were files are located
addpath(KeyPath);
demo = 'subject_anthropometry.xlsx'; % File containing demographic data to be imported

%% File Import
[~,~,demoRaw] = xlsread(demo);
sex = string(demoRaw(1,2:end));
mass = cell2table(demoRaw(4,2:end));
height = cell2table(demoRaw(5,2:end));