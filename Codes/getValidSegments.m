function lats = getValidSegments(EEG, TL)
    % 初始化输出的有效片段索引
    lats = [];

    % 读取数据长度
    totalLength = size(EEG.data, 2); % EEG 数据的总时间点数量

    % 遍历时间点，检查每个起点是否满足条件
    for i = 1:(totalLength - TL)
        % 取当前时间段的数据
        segment = EEG.data(:, i:i+TL-1);

        % 如果片段有效，记录其起点索引
        lats = [lats, i];
    end
end
