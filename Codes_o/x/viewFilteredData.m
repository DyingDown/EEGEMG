clear, clc
% 健康人

isDual = true;
% 指定文件夹路径

subj_no = "subj0";

base_folder = 'D:/Documents/Peng/EGG/Datasets/' + subj_no;

if isDual == false
    folderPath = 'D:/Documents/Peng/EGG/Datasets/subj0/filtered'; 
else 
    folderPath = 'D:/Documents/Peng/EGG/Datasets/subj0/filtered_dual'; 
end

% 获取文件夹中的所有文件和文件夹（包括隐藏文件）
fileList = dir(folderPath);

% 排除 '.' 和 '..' 文件夹
fileList = fileList(~ismember({fileList.name}, {'.', '..'}));

% 遍历文件列表
for i = 1:length(fileList)
    fileName = fileList(i).name;  % 获取文件或文件夹的名字
    filepath = fullfile(folderPath, fileName);  % 获取完整路径
    
    % 如果是文件，进行操作
    if ~fileList(i).isdir
        fprintf('处理文件: %s\n', filepath);
        % 在这里添加你希望对每个文件进行的操作
    else
        fprintf('子文件夹: %s\n', filepath);
        % 如果需要处理文件夹，递归遍历子文件夹
    end

    disp(filepath)
    fid = fopen(filepath);
    if fid == -1
        error('无法打开文件：%s', filepath);
    end
    % 不包含时间戳的数据格式
    datafile = textscan(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', 'CommentStyle', '#');
    
    
    fclose(fid);
    
    % 拆分EMG数据和EGG数据
    EMGData = [datafile{1:8}]; 
    EEGData = [datafile{9:24}];
    
    N1 = length(EMGData(1,:)); % EMG通道数量
    N2 = length(EEGData(1,:)); % EEG通道数量
    N = N1 + N2; % 总通道数量 24个，对应了24eegemg_sitstand_locs.ced文件里的24个
    DataLen = size(EMGData, 1); % 数据长度
    
    
    
    % 获取打点信息
    % startPoints = extract_startPoints(filepath);

    [~, filename, ~] = fileparts(fileName);

    events_path = fullfile(base_folder, 'sitstand', 'events_info', [filename, '_events_info.txt']);
    disp(events_path);

    % 读取事件数据
    events_data = readtable(events_path, 'Delimiter', '\t', 'ReadVariableNames', false);
    
    % 获取数据列
    latency = events_data{:, 2};  % 第二列：延迟
    marks = latency/1000;

    
    % 数据展示-不展示特定meg通道
    yrangeEMG = 200;
    yrangeEEG = 100;
    t = 0.001:0.001:length(EMGData(:,1))/1000; % 以秒为单位的时间向量
    offsets = zeros(N, 1); % 创建一个N*1的竖矩阵，所有元素为0， 用来在y轴体现偏移
    % close all
    figure(i)
    set(gcf, 'Name', ['Window ' fileName]);
    hold on
    for j=1:8
        %if j == 2 || j == 3
        %j=9不需要删除emg通道
        if ismember(j, [5])
            result = 0;
        else
            result = 1;
        end
        offsets(j) = yrangeEMG*(N1-j);
        plot(t, (EMGData(:,j)+offsets(j))*result)
    end
    for j=1:16
        if ismember(j, [17])
            result = 0;
        else
            result = 1;
        end
        offsets(N1+j) = yrangeEMG*(N1)+200+yrangeEEG*(16-j);
        plot(t, (EEGData(:,j)+offsets(N1+j))*result)
    end
    for j=1:length(marks)
        plot([marks(j) marks(j)], [-yrangeEMG yrangeEMG*8+200+yrangeEEG*16], 'k', 'LineWidth', 2)
        % %%%%%% 周期线
        % if mod(i, 2) == 1
        %         period = TL_a/1000; % a类周期
        % else
        %         period = TL_b/1000; % b类周期
        % end
        % plot([marks(i)+period marks(i)+period], [-yrangeEMG yrangeEMG*8+200+yrangeEEG*16], 'r', 'LineWidth', 2)
    
    end
    hold off
    channelLabels = {'TA','PL','MG','LG','RF','VM','LBF','Semi',...
        'P4','CP2','FC5','C3','P3','C2','FC6','C4','CP6','F3','FC2','FC1', 'F4',...
        'CP5','C1','CP1'};
    % Ensure offsets are sorted in increasing order
    [offsets_sorted, idx] = sort(offsets);
    % disp(idx);
    channelLabels_sorted = channelLabels(idx);
    
    % Plot settings
    set(gca, 'YTick', offsets_sorted, 'YTickLabel', channelLabels_sorted)
    xlim([0 30])
    ylim([-yrangeEMG yrangeEMG * N1 + yrangeEEG * N2 + 400]) 
end