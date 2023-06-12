% M3 Lab
% mvcComp.m
% Created 12 June 2023
% Mario Garcia | nfq3bd@virginia.edu
close all; clear; clc;

%% File Location
pathName = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Collected Data\Biodex\Biodex_Processed_Data\mMVC';
filePattern = fullfile(pathName,'*.mat') ;
matFiles = dir(filePattern) ; % Finds mat files that will be imported
for i = 1:length(matFiles) % Determines how many files will be imported
    baseFileName = matFiles(i).name ;
    fullFileName = fullfile(pathName, baseFileName) ;
    matdata = load(fullFileName) ;
    tempName = matdata.mMVC ;
    x = fieldnames(tempName);
    bd.(x{1}) = matdata.mMVC ;
    clear matdata
end
clear baseFileName filePattern fullFileName i matFiles pathName tempName

subID = fieldnames(bd);
momDir = fieldnames(bd.(subID{1}).(subID{1}));

for j = 1:8
    for k = 1:6
        for i = 1:length(subID)
            ang = fieldnames(bd.(subID{i}).(subID{i}).(momDir{j}));
            for l = 1:length(ang)
                joint{j}.(ang{l}).(subID{i}) = bd.(subID{i}).(subID{i}).(momDir{j}).(ang{l});
            end
        end
    end
    names{j} = [(momDir{j})];
end
joint = cell2struct(joint, names, 2);
clear i j k l momDir subID rep

