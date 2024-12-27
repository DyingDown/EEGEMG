% 打开文件
fid = fopen(filepath);
% 检查是否成功打开文件
if fid == -1
    error('无法打开文件: %s', filepath); % 输出错误信息并终止程序
else
    disp('文件成功打开'); % 文件打开成功时的提示
end

% 查找第一个和第二个包含 '#' 的行
foundFirstHash = false;

while true
    line = fgetl(fid);
    if ~ischar(line)
    break; % 到达文件末尾
end

if startsWith(line, '#')
    if foundFirstHash
        % 找到第二个 '#'，提取并处理其中的数字
        dataStr = strtrim(extractAfter(line, '#'));
        fprintf('Extracted data: %s\n', dataStr);
        % 将提取的数字转换为数组
        dataArray = sscanf(dataStr, '%f+'); % 支持以'+'分隔的数字解析
        dataArray = dataArray';
        fprintf('Extracted Array: \n');
        disp(dataArray); % 打印数组，转置为行显示
        break; % 找到目标行，退出循环
    else
        % 标记为已找到第一个 '#'
        foundFirstHash = true;
        data = strtrim(extractAfter(line, '#'));
        fprintf('Extracted data: %s\n', data);
    end
end
end