% M3 Lab
% lRegression.m
% Created 27 July 2023
% Mario Garcia | nfq3bd@virginia.edu
close all; clear; clc;

%% Required Value Import
% If changes have been made to volume data update mvcComp before running
run('mvcComp.m'); run('importVolume.m'); run('quintileAssign.m'); 
excludedSubjects = {'F07', 'M13'};
vol = rmfield(vol, excludedSubjects);

%% Sex Designation
id = fieldnames(vol);
m = contains(id, 'M');
f = contains(id, 'F');

%% Space Preallocation
numSubjects = numel(id);
t_equation_R{:,:} = ones(28, numSubjects);
t_R2_R = ones(28, numSubjects);
t_RMSE_R = ones(28, numSubjects); % Pre-allocate for raw torques with individual moment directions

%% Calculations
for i = 1:28
    %% Ankle Dorsiflexion
    if i <= 4
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Ankle.R.Dorsiflexion.Volume; % Extract dorsiflexion volume
            vc(1,j) = vol.(id{j}).Ankle.R.Dorsiflexion.Volume_Contract; % Extract dorsiflexion contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % A positive number means the r2 value increased with contractile
        % leading to better regression, a negative means it decreased,
        % column 1 is total, 2 is male, 3 is female
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);
        % A positive number means the rmse value decreased with contractile
        % leading to better regression, a negative means it decreased,
        % column 1 is total, 2 is male, 3 is female

    %% Ankle Plantarflexion
    elseif i>=5 && i<=8
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Ankle.R.PlantarFlexion.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Ankle.R.PlantarFlexion.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);

    %% Hip Abduction
    elseif i>=9 && i<=11
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Hip.R.Abduction.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Hip.R.Abduction.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);

    %% Hip Adduction
    elseif i>=12 && i<=14
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Hip.R.Adduction.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Hip.R.Adduction.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);

    %% Hip Extension
    elseif i>=15 && i<=17
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Hip.R.Extension.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Hip.R.Extension.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);

    %% Hip Flexion
    elseif i>=18 && i<=20
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Hip.R.Flexion.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Hip.R.Flexion.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);

    %% Knee Extension
    elseif i>=21 && i<=24
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Knee.R.Extension.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Knee.R.Extension.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);

    %% Knee Flexion
    else
        for j = 1:length(id)
            v(1,j) = vol.(id{j}).Hip.R.Flexion.Volume; % Extract plantar flexor volume
            vc(1,j) = vol.(id{j}).Hip.R.Flexion.Volume_Contract; % Extract plantar flexor contractile volume
        end
        % Torque Data
        t = data.Raw(i,:);
        % Torque Volume Linear Regression
        [t_eq_V{i,1}, t_R2_V(i,1), t_RMSE_V(i,1)] = linear_regression(v, t);
        [m_eq_V{i,1}, m_R2_V(i,1), m_RMSE_V(i,1)] = linear_regression(m.*v, m.*t);
        [f_eq_V{i,1}, f_R2_V(i,1), f_RMSE_V(i,1)] = linear_regression(m.*v, f.*t);
        % Torque Contractile Volume Linear Regression
        [t_eq_VC{i,1}, t_R2_VC(i,1), t_RMSE_VC(i,1)] = linear_regression(vc, t);
        [m_eq_VC{i,1}, m_R2_VC(i,1), m_RMSE_VC(i,1)] = linear_regression(m.*vc, m.*t);
        [f_eq_VC{i,1}, f_R2_VC(i,1), f_RMSE_VC(i,1)] = linear_regression(m.*vc, f.*t);
        % R2 Regression Comparision
        R2_Diff(i,1) = t_R2_VC(i,1)-t_R2_V(i,1);
        R2_Diff(i,2) = m_R2_VC(i,1)-m_R2_V(i,1);
        R2_Diff(i,3) = f_R2_VC(i,1)-f_R2_V(i,1);
        % RMSE Regression Comparision
        RMSE_Diff(i,1) = t_RMSE_V(i,1)-t_RMSE_VC(i,1);
        RMSE_Diff(i,2) = m_RMSE_V(i,1)-m_RMSE_VC(i,1);
        RMSE_Diff(i,3) = f_RMSE_V(i,1)-f_RMSE_VC(i,1);
    end
end