% M3 Lab
% biodexComparison.m
% Created 21 November 2022
% Mario Garcia | nfq3bd@virginia.edu

close all; clear; clc;

%% Loading Data
%pathName = 'C:\Users\nfq3bd\Desktop\Research\Sex Scaling\Data\Biodex\Biodex_Processed_Data'; % Select folder containing data
pathName = 'C:\Users\quent\Biodex\Raw';
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


subID = fieldnames(bd);
momDir = fieldnames(bd.(subID{1}).(subID{1}));
format = fieldnames(bd.(subID{1}).(subID{1}).(momDir{1}));

for j = 1:8
    for k = 1:6
        if k < 3
            for i = 1:length(subID)
                ang = fieldnames(bd.(subID{i}).(subID{i}).(momDir{j}).(format{k}));
                for l = 1:length(ang)
                    rep = fieldnames(bd.(subID{i}).(subID{i}).(momDir{j}).(format{k}).(ang{l}));
                    joint{j}.(format{k}).(ang{l}).(subID{i}).(rep{1}) = bd.(subID{i}).(subID{i}).(momDir{j}).(format{k}).(ang{l}).(rep{1});
                    joint{j}.(format{k}).(ang{l}).(subID{i}).(rep{2}) = bd.(subID{i}).(subID{i}).(momDir{j}).(format{k}).(ang{l}).(rep{2});
                end
            end
        else
            for i = 1:length(subID)
                ang = fieldnames(bd.(subID{i}).(subID{i}).(momDir{j}).(format{k}));
                for l = 1:length(ang)
                    joint{j}.(format{k}).(ang{l}).(subID{i}) = bd.(subID{i}).(subID{i}).(momDir{j}).(format{k}).(ang{l});
                end
            end
        end
    end
    names{j} = [(momDir{j})];
end
joint = cell2struct(joint, names, 2);
clear i j k l momDir subID rep

