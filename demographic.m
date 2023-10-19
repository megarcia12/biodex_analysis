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
[~,~,demoRaw] = xlsread(demo); % Reads in excel file 

%% Anthro Struct
anthro = struct(); % Saves subject structures into single anthro structure 
subid = demoRaw(3:end,1); % Extracts subject IDs from raw data
cat = demoRaw(1,7:end-9); % Names of measurement for body anthro measurements
Sex = []; Age = []; Height = []; Mass  = []; % Initiates variables

for i = 1:numel(subid) % loop through each subject
    sub = demoRaw{i+2,1}; % create variable name for each subject

    % Corresponding value for each category
    anthro.(sub).General.Sex = sub(1); % Saves sex from anthro excel file to structure
    anthro.(sub).General.Age = demoRaw{i+2,2}; % Saves age from anthro excel file to structure
    anthro.(sub).General.Mass = demoRaw{i+2,5}; % Saves mass from anthro excel file to structure
    anthro.(sub).General.Height = demoRaw{i+2,6}; % Saves height  from anthro excel file to structure

    % Corresponding value for population description
    Sex = [Sex; sub(1)]; % Saves sex from anthro excel file
    Age = [Age; demoRaw{i+2,2}]; % Saves age from anthro excel file
    Mass = [Mass; demoRaw{i+2,5}]; % Saves mass from anthro excel file
    Height = [Height; demoRaw{i+2,6}]; % Saves height from anthro excel file

    % Body measurements
    for j = 1:numel(cat)
        str = cat{j}; % iterates through the measurements to save in structure
        strName = strrep(str, '-', '');  % delete hyphen
        split = strsplit(strName,'('); % cut string at first parenthese, delete (mm)
        newStr = split{1}; % Creates new string from split
        measure = genvarname(newStr); % create new string without mm
        % Create variable for each measurement and input values
        anthro.(sub).Measures.(measure) = demoRaw{i+2,j+6}; % Saves variable name and lenght
    end
end

%% Sex Boolean
m = contains(string(Sex)','M'); % Binary for male
f = contains(string(Sex)','F'); % Binary for female

%% Removal of Subjects not included
idxToRemove = flip([4, 6, 14, 21]);
% Corresponds to [F05 F07 M06 M13]
m(idxToRemove) = []; f(idxToRemove) = []; % Removes subjects 
Age(idxToRemove) = []; Height(idxToRemove) = []; Mass(idxToRemove) = []; % Removes subjects

% Subject Variables
anthro.Total.Age = [mean(Age) std(Age)]; % Caclulates mean and standard deviation for age for the combined subject population
anthro.Male.Age = [mean(nonzeros(Age(m))) std(nonzeros(Age(m)))]; % Caclulates mean and standard deviation for age for the male subject population
anthro.Female.Age = [mean(nonzeros(Age(f))) std(nonzeros(Age(f)))]; % Caclulates mean and standard deviation for age for the female subject population

anthro.Total.Height = [mean(Height) std(Height)];  % Caclulates mean and standard deviation for height for the combined subject population
anthro.Male.Height = [mean(nonzeros(Height(m))) std(nonzeros(Height(m)))];  % Caclulates mean and standard deviation for height for the male subject population
anthro.Female.Height = [mean(nonzeros(Height(f))) std(nonzeros(Height(f)))];  % Caclulates mean and standard deviation for height for the female subject population

anthro.Total.Mass = [mean(Mass) std(Mass)]; % Caclulates mean and standard deviation for mass for the combined subject population
anthro.Male.Mass = [mean(nonzeros(Mass(m))) std(nonzeros(Mass(m)))]; % Caclulates mean and standard deviation for mass for the male subject population
anthro.Female.Mass = [mean(nonzeros(Mass(f))) std(nonzeros(Mass(f)))]; % Caclulates mean and standard deviation for mass for the female subject population

% Raw data saving
anthro.Total.Raw.Age = Age; 
anthro.Male.Raw.Age = nonzeros(Age(m)); 
anthro.Female.Raw.Age = nonzeros(Age(f)); % Saves age raw data without zeros

anthro.Total.Raw.Height = Height; 
anthro.Male.Raw.Height = nonzeros(Height(m)); 
anthro.Female.Raw.Height = nonzeros(Height(f)); % Saves height raw data without zeros

anthro.Total.Raw.Mass = Mass; 
anthro.Male.Raw.Mass = nonzeros(Mass(m)); 
anthro.Female.Raw.Mass = nonzeros(Mass(f)); % Saves mass raw data without zeros

%% Variable Cleaning
clear cat height i j KeyPath mass measure newStr split str strName sub subid val sex demo Age f Height m Mass Sex limbRaw idxToRemove demoRaw