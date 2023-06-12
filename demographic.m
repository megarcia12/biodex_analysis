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
height = cell2table(demoRaw(5,2:end));

%% Anthro Struct
anthro = struct();
subid = demoRaw(1,2:end);
cat = demoRaw(6:24,1); 

for i = 1:numel(subid) % loop through each subject
    sub = demoRaw{1, i+1}; % create variable name for each subject
    %sub = genvarname(val);

    % Corresponding value for each category
    anthro.(sub).General.Sex = sub(1);
    anthro.(sub).General.Age = demoRaw{2,i+1};
    anthro.(sub).General.Mass = demoRaw{4,i+1};
    anthro.(sub).General.Height = demoRaw{5,i+1};

    % Body measurements
    for j = 1:numel(cat)
        str = cat{j};
        strName = strrep(str, '-', '');  % delete hyphen
        split = strsplit(strName,'('); % cut string at first parenthese, delete (mm)
        newStr = split{1};
        measure = genvarname(newStr); % create new string without mm
        % Create variable for each measurement and input values
        anthro.(sub).Measures.(measure) = demoRaw{j+5,i+1}; 
    end

end

%% Variable Cleaning
clear cat height i j KeyPath mass measure newStr split str strName sub subid val sex demo
