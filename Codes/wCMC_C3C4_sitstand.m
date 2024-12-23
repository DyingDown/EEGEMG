Fs = 1000;
% TL = 5200*Fs/1000;%P4、P5
TL = 3000*Fs/1000;%P4、P5
subj_no = "subj1";
%分运动方向、EEG频带分析
% dirs = ['b', 'c', 'd', 'e', 'f', 'g', 'h'];
dirs = ['a'];
filename = erase(EEG.filename, '.set');
for idx = 1:length(dirs)
    dEEG = pop_rmdat(EEG, {dirs(idx)}, [0, TL/Fs],0);   %选取特定方向的动作段
    dEEG.setname = filename + "_dir_"+dirs(idx);
    aEEG = dEEG;
end

% 各肌电通道定义
EMG_chs = [1, 2, 3, 4, 5, 6, 7, 8]; % 分别为 TA, PL, MG, LG, RF, VM, LBF, SEM
EMG_labels = {'TA', 'PL', 'MG', 'LG', 'RF', 'VM', 'LBF', 'SEM'};

% EEG通道定义
EEG1ch = 12;%C3
EEG2ch = 16;%C4

lats = getValidSegments(aEEG, TL); 
N = length(lats); 

% 初始化存储变量
C3 = zeros(TL, N);
C4 = zeros(TL, N);

for j = 1:length(EMG_labels)
    eval([EMG_labels{j}, '= zeros(TL, N);']);
end

% 数据分段提取
for i = 5:N
    idx = lats(i);
    try
        % 提取EMG信号
        for j = 1:length(EMG_chs)
            eval([EMG_labels{j}, '(:,i) = aEEG.data(EMG_chs(j),idx:idx+TL-1)'';']);
        end
        % 提取EEG信号
        C3(:, i) = aEEG.data(EEG1ch, idx:idx+TL-1)';
        C4(:, i) = aEEG.data(EEG2ch, idx:idx+TL-1)';
    catch
        N = N - 1;
    end
end

% 分批次计算并保存
for j = 5:length(EMG_labels)
    label = EMG_labels{j};
    
    fprintf("Start processing %s C3\n", label);
    [wcohere_C3, ~, ~] = calcCMC(C3, eval(label), N, TL, Fs);
    fprintf("Finished %s C3\n", label);
    
    fprintf("Start processing %s C4\n", label);
    [wcohere_C4, ~, ~] = calcCMC(C4, eval(label), N, TL, Fs);
    fprintf("Finished %s C4\n", label);
    
    break;
    % 分别保存C3和C4的结果
    save_path = "D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/" + subj_no + "/" + ...
                aEEG.setname + "_CMCvalues_" + label + ".mat";
    save(save_path, 'wcohere_C3', 'wcohere_C4');
    
    fprintf("Saved results for %s\n", label);
end