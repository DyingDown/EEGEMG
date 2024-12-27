clear, clc
% patient
subjno = 'subj2';
%subj1(������)
%subj2(�Ž���)
%subj3(������)
%subj4(������)
%%%% �ڶ����������� %%%%
%subj5(���¿�)
%subj6(���¾�)
%subj7(��ǿ)
%%%%%%%�ȷ���8��9 %%%%%%%%
%subj8(������)
%subj9(�ް�)


%������

motion = 'sitstand';


%%%%%%%%%%%%%%%%%%%%
test_num = 'test2';
week_num = "week1";
filepath = strcat('D:/Documents/Peng/EGG/Datasets/', subjno, '/', motion, '_', week_num,'/', test_num, '.txt');  %�ļ�·�����ļ���
disp(filepath)
fid = fopen(filepath);
if fid == -1
    error('�޷����ļ���%s', filepath);
end
% ������ʱ��������ݸ�ʽ
datafile = textscan(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', 'CommentStyle', '#');

%{
% ����ʱ��������ݸ�ʽ
datafile = textscan(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f:%f:%f\r\n', 'CommentStyle', '#');
Timestamps = [datafile{33:35}];   %�ں����������а���ʱ���
startTime = [11 12 23.000];     %������ʼʱ�̣���ʱ���ð�ţ��滻�ɿո�򶺺ţ�%�����rest�ļ����Ͱ��ļ����е�ʱ�����룬���С���������λ��0����
if startTime(1) > 12
    startTime(1) = startTime(1)-12;
end
startP = 0;
for k=1:length(Timestamps(:,1))
    if Timestamps(k,:) == startTime
        startP = k;
        break
    end
end
%}

fclose(fid);

% ���EMG���ݺ�EGG����
EMGData = [datafile{1:8}]; 
EEGData = [datafile{17:32}];

N1 = length(EMGData(1,:)); % EMGͨ������
N2 = length(EEGData(1,:)); % EEGͨ������
N = N1 + N2; % ��ͨ������ 24������Ӧ��24eegemg_sitstand_locs.ced�ļ����24��
DataLen = size(EMGData, 1); % ���ݳ���


%{
    �˲������ⲿ�ִ��������ͼ��չʾʱ���ã�����鿴�ֶν�����ڱ��������ļ�ʱע�ͣ���������Ľ����ԭʼδ�˲�����

    �ݲ��˲�: ���� 50Hz ��Ƶ���ż��䱶Ƶ���ţ������ڵ��������ݲɼ�ʱ�ĵ�����������
    ��ͨ�˲�:
        EMG �ź��˲��� 20-150Hz ��Χ�������������ݵ���ҪƵ�Ρ�
        EEG �ź��˲��� 1-49Hz�������Ե����ݵ���ҪƵ�Ρ�
%}

fs=1000; % ����Ƶ��
for i=1:9   % ��Ƶ�˲� ����50Hz��Ƶ���ż��䱶Ƶ����
    [b,a]=butter(2, [2*(50*i-1)/fs,2*(50*i+1)/fs], "stop");
    EMGData=filter(b,a,EMGData);
    EEGData=filter(b,a,EEGData);
end

%EMGData = abs(EMGData); %�������ɵ����Ƿ���Ҫ����
[b,a]=butter(4, [2*20/fs,2*150/fs],"bandpass"); %EMG 20-150Hz��ͨ
EMGData=filter(b,a,EMGData);
[b,a]=butter(4, [2*1/fs,2*49/fs],"bandpass"); %EEG 1-49Hz��ͨ
EEGData=filter(b,a,EEGData);

% ��ȡ�����Ϣ
startPoints = extract_startPoints(filepath);
marks = startPoints/1000;

% ����չʾ-��չʾ�ض�megͨ��
yrangeEMG = 200;
yrangeEEG = 100;
t = 0.001:0.001:length(EMGData(:,1))/1000; % ����Ϊ��λ��ʱ������
offsets = zeros(N, 1); % ����һ��N*1������������Ԫ��Ϊ0�� ������y������ƫ��
close all
figure(1)
hold on
for i=1:8
    %if i == 2 || i == 3
    %i=9����Ҫɾ��emgͨ��
    if ismember(i, [5])
        result = 0;
    else
        result = 1;
    end
    offsets(i) = yrangeEMG*(N1-i);
    plot(t, (EMGData(:,i)+offsets(i))*result)
end
for i=1:16
    if ismember(i, [17])
        result = 0;
    else
        result = 1;
    end
    offsets(N1+i) = yrangeEMG*(N1)+200+yrangeEEG*(16-i);
    plot(t, (EEGData(:,i)+offsets(N1+i))*result)
end
for i=1:length(marks)
    plot([marks(i) marks(i)], [-yrangeEMG yrangeEMG*8+200+yrangeEEG*16], 'k', 'LineWidth', 2)
    % %%%%%% ������
    % if mod(i, 2) == 1
    %         period = TL_a/1000; % a������
    % else
    %         period = TL_b/1000; % b������
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



%% �������-�ֶ��ҹ���
% ��ȡ��ǰ�ļ���Ŀ¼
splitidx = strfind(filepath, '/');
fprintf("len=%d\n", strlength(filepath));
splitidx = splitidx(end);
% disp(splitidx-1)
% ��ȡ��һ��Ŀ¼
disp(filepath(1))
parentFolderPath = extractBetween(filepath,1,splitidx-1); % ȥ��ĩβ�� "/"
lastSlashIdx = strfind(parentFolderPath, '/'); % �ҵ���һ��·���ָ���
lastSlashIdx = lastSlashIdx(end); % ��һ��·����ĩβλ��
parentFolderPath = extractBetween(parentFolderPath, 1, lastSlashIdx); % ��ȡ��һ��Ŀ¼·��

% �޸�Ϊ��һ��Ŀ¼�µ� "sitstand" �ļ���
folderpath = fullfile(parentFolderPath, 'sitstand'); % ƴ���µ��ļ���·��
disp(folderpath);

% filterfile = [subjno, '_', TMS, '_', 'filtered_', filepath(splitidx+1:end)];
filterfile = strcat(subjno, '_', 'raw_processed_', week_num, '_', extractAfter(filepath, splitidx));
disp(filterfile);
fullpath = fullfile(folderpath, filterfile);
fprintf("fullpath=%s\n", fullpath);
fid = fopen(fullpath, 'w');


% TL_a �¼�a��վ��������ʼʱ�� 
% TL_b b������������ʼʱ��
fprintf('Data Len = %d\n', DataLen);  % ��ӡ�����ܳ���
TL_a = 6000;
TL_b = 4200;
TL = TL_a + TL_b;
disp(startPoints);

save_idx = [];
%����1:1+TL_a�洢���ǵ�һ����ʼ�㵽�յ��ʵ��������
for i = 1:length(startPoints)    
    save_idx = [save_idx startPoints(i):(startPoints(i)+TL)];
end
%������ʱ���
combineddata=[EMGData(save_idx,:) EEGData(save_idx,:)]';
fprintf(fid, '%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\r\n', combineddata);
%����ʱ���
% combineddata=[EMGData(startP:end,:) EEGData(startP:end,:) Timestamps(startP:end,:)]';
% fprintf(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d %d %.3f\r\n', combineddata);
fclose(fid);
