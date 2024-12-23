clear, clc
subjno = 'subj0';
motion = 'sitstand';
test = 1;
isDualSP = true; % is the data contains dual startpoint for both starnd up and sit down

% 指定文件夹路径
if isDualSP == false
    folderPath = 'D:/Documents/Peng/EGG/Datasets/subj0/filtered'; 
else
    folderPath = "D:/Documents/Peng/EGG/Datasets/subj0/dual_start_points";
end

%%%%%%% 先创建文件夹 %%%%%%%
% 定义多次实验的参数

%s00:
experiments = struct('TL_a', 3000, 'TL_b', 3000);

% %s02:
% experiments = [
%     struct('k', 1, 'TL_a', 4500, 'TL_b', 2000, 'n', 16);
%     struct('k', 2, 'TL_a', 4500, 'TL_b', 2000, 'n', 20);
%     struct('k', 3, 'TL_a', 4000, 'TL_b', 2000, 'n', 12);
%     struct('k', 4, 'TL_a', 3000, 'TL_b', 2000, 'n', 18)
% ];
% 
% 
% %s03
% experiments = [
%     struct('k', 1, 'TL_a', 3000, 'TL_b', 2000, 'n', 16);
%     struct('k', 2, 'TL_a', 7000, 'TL_b', 5000, 'n', 12);
%     struct('k', 3, 'TL_a', 4000, 'TL_b', 2000, 'n', 12);
%     struct('k', 4, 'TL_a', 3000, 'TL_b', 2000, 'n', 18)
% ];




% TL_a 站起来的持续时间
% TL_b 坐下来的持续时间
TL_a = 6000;
TL_b = 4200;



% 获取文件夹中的所有文件和文件夹（包括隐藏文件）
fileList = dir(folderPath);

% 排除 '.' 和 '..' 文件夹
fileList = fileList(~ismember({fileList.name}, {'.', '..'}));

% 遍历文件列表
for k = 7:length(fileList)

    fileName = fileList(i).name;  % 获取文件或文件夹的名字
    filepath = fullfile(folderPath, fileName);  % 获取完整路径

% for i = 1:4

    fprintf("week %d\n", i - 1);
    % experiment = experiments(i);
    % k = experiment.k;
    % TL_a = experiment.TL_a;
    % TL_b = experiment.TL_b;
    % n = experiment.n;

    % 获取打点数据  week从0开始
    % filepath = strcat(path_prefix, "/", subjno, "/", motion, "_test", num2str(test), "/week", num2str(i - 1), ".txt");
    startPoints = extract_startPoints(filepath);
    disp(startPoints)
    len = length(startPoints); 
    
    filename = strcat(subjno, '_week', num2str(i - 1), '_events_info');
    filepath = fullfile('D:/Documents/Peng/EGG/Datasets', subjno, motion, 'events_info',[filename, '.txt']);

    eventInfo = cell(len * 2, 3); % 事件信息的储存矩阵

    start = 1;
    for j = 1:len*2 
        if mod(j, 2) == 1
            eventType = 'a'; % a类事件
            period = experiments.TL_a; % a类周期
        else
            eventType = 'b'; % b类事件
            period = experiments.TL_b; % b类周期
        end
        eventInfo{j, 1} = eventType;
        eventInfo{j, 2} = start;
        eventInfo{j, 3} = period;
        start = start + period; % 更新起始点
    end
    
    disp(eventInfo);
    % 确保目标文件夹存在
    [folder, ~, ~] = fileparts(filepath);
    if ~exist(folder, 'dir')
        fprintf("不存在，新建路径", folder);
        mkdir(folder); % 如果不存在，创建文件夹
    end

    fid = fopen(filepath, 'w'); % 打开文件
    % if fid == -1
    %     error('文件夹不存在'); % 如果文件打开失败，抛出错误
    % end

    for j = 1:len*2
        fprintf(fid, '%s\t%d\t%d\n', eventInfo{j, :}); % 写入事件信息，注意顺序
    end

    fclose(fid); % 关闭文件
end