% 模拟数据 (使用真实数据时替换以下)
fs = 1000;          % 采样率（Hz）
t = 0:1/fs:3;       % 3秒数据时间轴
muscle_names = {'BIC', 'TRI', 'DM', 'DA', 'DP'};  % 肌肉名称
eeg_channels = {'C3', 'C4'};                      % EEG通道名称

% 加载 .mat 数据
taData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj1/subj1_week2_afterICA_dir_a_CMCvalues_TA.mat');
plData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj1/subj1_week2_afterICA_dir_a_CMCvalues_PL.mat');
rfData = load('D:/Documents/Peng/EGG/Datasets/CMCresult_lowerLimb/subj1/subj1_week2_afterICA_dir_a_CMCvalues_RF.mat');


% 小波频率范围
freq_range = 1:0.5:50;  % 可以根据需求调整频率范围
% 假设 wcohere_MGvsC3 是计算好的小波相干值矩阵，time 和 freq 是时间和频率轴
% wcohere_MGvsC3, wcohere_RFvsC3, 等等

% 2. 设置绘图参数
channels = {'TA-C3', 'TA-C4', 'PL-C3', 'PL-C4', "RF-C3", "RF-C4"}; % 替换为你的肌肉-脑区名称
results = {taData.wcohere_C3, taData.wcohere_C4, plData.wcohere_C3, plData.wcohere_C4, rfData.wcohere_C3, rfData.wcohere_C4}; % 数据按顺序
freq = 1:50; % 频率范围 (Hz)，调整到你的范围
time = linspace(0, 3000, size(wcohere_MGvsC3, 2)); % 时间 (ms)

% 3. 创建子图
figure;
for i = 1:length(results)
    subplot(4, 2, i);
    imagesc(time, freq, results{i});
    axis xy; % 确保频率轴是正序
    colormap('jet'); % 设置颜色
    colorbar; % 显示颜色条
    caxis([0, 0.4]); % 限定颜色范围，根据数据调整
    title(channels{i}, 'Interpreter', 'none');
    xlabel('Time (ms)');
    ylabel('Frequency (Hz)');
end

% 4. 添加整体图标题
sgtitle('小波相干分析结果 (MG和RF vs C3/C4)');


% % 图像参数设置
% figure;
% for i = 1:num_muscles
%     for j = 1:num_channels
%         % 计算EEG/EMG时频图
%         [wt, f] = customMorletCWT(emg_data(i, :), fs, freq_range);  % EMG的小波变换
%         subplot(num_muscles, num_channels, (i-1)*num_channels + j); % 子图
%         imagesc(t, f, abs(wt));  % 绘制小波图
%         set(gca, 'YDir', 'normal');  % Y轴正方向向上
%         colorbar;  % 颜色条
%         caxis([0, 0.4]);  % 设置颜色范围（按你的需要调整）
% 
%         % 添加标题与标签
%         if i == 1
%             title(sprintf('%s-%s', muscle_names{i}, eeg_channels{j})); % 每列标题
%         end
%         if j == 1
%             ylabel(sprintf('%s', muscle_names{i}));  % 每行标签
%         end
%         if i == num_muscles
%             xlabel('Time (s)');  % 只在最后一行设置时间标签
%         end
%     end
% end
% 
% % 总标题
% sgtitle('脑肌耦合时频域结果（小波变换）');

% function [wt, f] = customMorletCWT(signal, fs, freq_range)
%     % 自定义 Morlet 母小波并实现小波变换
%     scales = fs ./ freq_range; % 根据频率范围设置小波尺度
%     f = freq_range;            % 输出频率向量
%     wt = zeros(length(scales), length(signal)); % 初始化小波系数
% 
%     for idx = 1:length(scales)
%         scale = scales(idx);
%         % 检查 `scale` 的合法性，并生成时间窗口
%         t = -4*scale:1/fs:4*scale; % 时间窗口长度
%         fc = 1; % 母小波中心频率
%         morlet_wavelet = (pi^(-0.25)) * exp(-t.^2/(2*scale^2)) .* exp(1i*2*pi*fc*t);
% 
%         % 对信号执行卷积
%         wt(idx, :) = conv(signal, morlet_wavelet, 'same');
%     end
% end
