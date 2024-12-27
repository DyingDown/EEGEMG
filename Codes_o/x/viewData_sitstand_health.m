% function processeRawData(subj_no, isDual, baseFolderPath, Fs, TL_a, TL_b)
% clear, clc
% 健康人

isDual = true;
% 指定文件夹路径

subj_no = "subj5";

if isDual == false
    dataFolderPath = 'D:/Documents/Peng/EGG/Datasets/' + subj_no + '/original'; 
else 
    dataFolderPath = 'D:/Documents/Peng/EGG/Datasets/' + subj_no + '/dual_start_points'; 
end


% TL_a 事件a（站起来）开始时间   
% TL_b b（坐下来）开始时间
TL_a = 3000;
TL_b = 3000;
TL = TL_a + TL_b;

% 获取文件夹中的所有文件和文件夹（包括隐藏文件）
fileList = dir(dataFolderPath);

% 排除 '.' 和 '..' 文件夹
fileList = fileList(~ismember({fileList.name}, {'.', '..'}));

close all

disp(fileList)

% 遍历文件列表
for i = 1:length(fileList)
    fileName = fileList(i).name;  % 获取文件或文件夹的名字
    filepath = fullfile(dataFolderPath, fileName);  % 获取完整路径
    
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
    % datafile = textscan(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', 'CommentStyle', '#');
    datafile = textscan(fid, repmat('%f', 1, 32), 'Delimiter', '\t', 'CommentStyle', '#');
    
    fclose(fid);
    
    % 拆分EMG数据和EGG数据
    EMGData = [datafile{1:8}]; 
    EEGData = [datafile{17:32}];
    
    N1 = length(EMGData(1,:)); % EMG通道数量
    N2 = length(EEGData(1,:)); % EEG通道数量
    N = N1 + N2; % 总通道数量 24个，对应了24eegemg_sitstand_locs.ced文件里的24个
    DataLen = size(EMGData, 1); % 数据长度
    
    
    %{
        滤波处理，这部分代码可以在图表展示时启用，方便查看分段结果；在保存结果到文件时注释，这样保存的结果是原始未滤波数据
    
        陷波滤波: 消除 50Hz 工频干扰及其倍频干扰（常见于电生理数据采集时的电力噪声）。
        带通滤波:
            EMG 信号滤波到 20-150Hz 范围，保留肌电数据的主要频段。
            EEG 信号滤波到 1-49Hz，保留脑电数据的主要频段。
    %}
    
    fs=1000; % 采样频率
    for j=1:9   % 工频滤波 消除50Hz工频干扰及其倍频干扰
        [b,a]=butter(2, [2*(50*j-1)/fs,2*(50*j+1)/fs], "stop");
        EMGData=filter(b,a,EMGData);
        EEGData=filter(b,a,EEGData);
    end
    
    %EMGData = abs(EMGData); %整流，可调整是否需要整流
    [b,a]=butter(4, [2*20/fs,2*150/fs],"bandpass"); %EMG 20-150Hz带通
    EMGData=filter(b,a,EMGData);
    [b,a]=butter(4, [2*1/fs,2*49/fs],"bandpass"); %EEG 1-49Hz带通
    EEGData=filter(b,a,EEGData);
    
    % 获取打点信息
    startPoints = extract_startPoints(filepath);

    disp(startPoints)
    marks = [];
    for j = 1:length(startPoints)
        if isDual == true
            marks = [marks, startPoints(j) / 1000 - 1.5, startPoints(j)/1000, startPoints(j) / 1000 + 1.5]; % 打点位置为峰值
        else
            marks = [marks, startPoints(j) / 1000];
        end
    end

    disp(marks);
    
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
    
    
    
    %% 结果保存-分段且过滤
    % 获取当前文件的目录
    splitidx = strfind(filepath, filesep);  % 使用 filesep 作为路径分隔符
    if isempty(splitidx)
        error('路径中没有分隔符: %s', filepath);
    end
    
    splitidx = splitidx(end);  % 获取最后一个路径分隔符的位置

    % 获取上一级目录
    parentFolderPath = extractBetween(filepath, 1, splitidx-1); % 去掉末尾的 "/"
    fprintf("parentFolderPath=%s\n", parentFolderPath);
    lastSlashIdx = strfind(parentFolderPath, '\'); % 找到上一级路径分隔符
    lastSlashIdx = lastSlashIdx(end); % 上一级路径的末尾位置
    parentFolderPath = extractBetween(parentFolderPath, 1, lastSlashIdx); % 获取上一级目录路径
    
    % 修改为上一级目录下的 filtered 文件夹
    
    if isDual == false
        processedDataFolderPath = fullfile(parentFolderPath, 'filtered'); % 拼接新的文件夹路径
    else
        processedDataFolderPath = fullfile(parentFolderPath, 'filtered_dual'); % 拼接新的文件夹路径
    end
    disp(processedDataFolderPath);
    fprintf("processedDataFolderPath=%s\n", processedDataFolderPath);
    if ~exist(processedDataFolderPath, 'dir')
        mkdir(processedDataFolderPath); % 如果目录不存在，创建目录
        fprintf('Directory created: %s\n', processedDataFolderPath);
    end

    [~, nameWithoutExtension, ~] = fileparts(fileName);
    nameWithoutExtension = [nameWithoutExtension, '_raw_processed.txt'];

    fullpath = fullfile(processedDataFolderPath, nameWithoutExtension);
    disp(fullpath)
    fprintf("fullpath = %s\n", fullpath);
    fid = fopen(fullpath, 'w');
    
   
    if fid == -1
        error('无法打开文件：%s', fullpath);
    end


    fprintf('Data Len = %d\n', DataLen);  % 打印数据总长度

    disp(startPoints);
    
    save_idx = [];
    if isDual == false
        %索引1:1+TL_a存储的是第一个起始点到终点的实际索引。
        for j = 1:length(startPoints)    
            save_idx = [save_idx startPoints(j):(startPoints(j)+TL)];
        end
    else 
        for j = 1:length(startPoints)    
            if mod(j, 2) == 1
                save_idx = [save_idx (startPoints(j)-TL_a/2):(startPoints(j)+TL_a/2)];
            else
                save_idx = [save_idx (startPoints(j)-TL_b/2):(startPoints(j)+TL_b/2)];
            end
        end
    end

    %不包含时间戳
    combineddata=[EMGData(save_idx,:) EEGData(save_idx,:)]';
    fprintf(fid, '%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\r\n', combineddata);
    %包含时间戳
    % combineddata=[EMGData(startP:end,:) EEGData(startP:end,:) Timestamps(startP:end,:)]';
    % fprintf(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d %d %.3f\r\n', combineddata);
    fclose(fid);
end
% end
    

