clear, clc
% patient
subjno = 'subj9';
%subj1(������)
%subj2(�Ž���)
%subj3(������)
%subj4(������)
%%%% �ڶ����������� %%%%
%subj5(���¿�)
%subj6(���¾�)
%subj7(��ǿ)
%subj8(������)��ʱ������
%subj9(�ް�)


%������

motion = 'sitstand';


%%%%%%%%%%%%%%%%%%%%
session = 'week0';
test_num = 'test1';
filepath = ['D:\EEG\�������Ŀ\data_rename\', subjno, '/', motion '_' test_num,'/', session, '.txt'];  %�ļ�·�����ļ���

fid = fopen(filepath);
% ������ʱ��������ݸ�ʽ
datafile = textscan(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n', 'CommentStyle', '#');

fclose(fid);

EMGData = [datafile{1:8}];
EEGData = [datafile{17:32}];

%187410

% �˲����ⲿ�ִ��������ͼ��չʾʱ���ã�����鿴�ֶν�����ڱ��������ļ�ʱע�ͣ���������Ľ����ԭʼδ�˲�����
if 1
    fs=1000;
    for i=1:9   %��Ƶ�˲�
        [b,a]=butter(2, [2*(50*i-1)/fs,2*(50*i+1)/fs], "stop");
        EMGData=filter(b,a,EMGData);
        EEGData=filter(b,a,EEGData);
    end
    
    %EMGData = abs(EMGData); %�������ɵ����Ƿ���Ҫ����
    %emg��eeg�˲�������һ���ᵼ������ά���в����
    [b,a]=butter(4, [2*20/fs,2*150/fs],"bandpass"); %EMG 20-150Hz��ͨ
    EMGData=filter(b,a,EMGData);
    [b,a]=butter(4, [2*1/fs,2*49/fs],"bandpass"); %EEG 1-49Hz��ͨ
    EEGData=filter(b,a,EEGData);
end

% �ֶ������ν�ȡ

if strcmp(subjno, 'subj1')
    if strcmp(session, 's01')
        %n=14
        startP = [6409 17358 27775 42048 48995 61784 68006 79500 89859 103914 113663 133754 150008 164372];
        TL_a = 5400;
        TL_b = 3000;
    elseif strcmp(session, 's02')
        %n=12
        startP = [38965 48163 56643 63208 68699 76249 88081 95871 106418 115126 136924 142735];
        TL_a = 5400;
        TL_b = 2500;
    elseif strcmp(session, 's03')
        %n=18
        startP = [18032 23745 26504 31439 35545 40945 62087 67202 76761 82740 99999 106863 113432 119604 123872 129724 134347 145518];
        TL_a = 3500;
        TL_b = 2500;
    elseif strcmp(session, 's04')
        %n=26
        startP = [4779 9296 24089 28489 34087 40291 46047 51057 57468 63329 69106 74776 80661 86742 ...
    91560 96712 100865 105892 110040 114197 117480 122320 128453 133809 138661 144732];
        TL_a = 3300;
        TL_b = 2000;
    else
        error('Invalid session');
    end
elseif strcmp(subjno, 'subj2')
    if strcmp(session, 's01')
        startP = [14584 23332 27139 35778 56718 66489 70705 79101 84369 92349 98115 109153 135628 143489 147096 156398];
        TL_a = 4500;
        TL_b = 2000;
    elseif strcmp(session, 's02')
        startP = [9999 19695 24538 35006 40196 49449 54154 64053 67959 75916 84011 92156 98214 106727 111574 119418 123195 130838 134959 141885];
        TL_a = 4500;
        TL_b = 2000;
    elseif strcmp(session, 's03')
        startP = [27979 36862 39832 50451 53279 62749 65381 74116 77335 85281 88452 96234];
        TL_a = 4000;
        TL_b = 2000;
    elseif strcmp(session, 's04')
        startP = [19432 27418 30326 39090 64366 72827 76030 83685 86920 95849 100320 108272 113596 122227 125878 136108 140425 147973];
        TL_a = 3000;
        TL_b = 2000;
    else
        error('Invalid session');
    end
elseif strcmp(subjno, 'subj3')
    if strcmp(session, 's01')
        startP = [27526 37063 41931 47696 54149 59278 81085 86183 133111 139265 149525 157628 161663 167043 171573 182210];
        TL_a = 3000;
        TL_b = 2000;
    elseif strcmp(session, 's02')
        startP = [16366 25164 33757 43062 50804 58653 66693 75047 83162 93421 118079 125966];
        TL_a = 7000;
        TL_b = 5000;
    elseif strcmp(session, 's04')
        startP = [1];
    else
        error('Invalid session');
    end
elseif strcmp(subjno, 'subj4')
    if strcmp(session, 's01')
        startP = [24638 34413 44349 53615 66393 74499 122416 131763 141836 149431];
        TL_a = 5000;
        TL_b = 2500;
    elseif strcmp(session, 's02')
        startP = [49720 58576 80138 89446 103972 109344 117365 124263 136071 142551];
        TL_a = 4000;
        TL_b = 3500;
    elseif strcmp(session, 's04')
        startP = [69545 75224 80850 85414 89683 95028 101865 106519 111394 114791];
        TL_a = 3000;
        TL_b = 2000;
    else
        error('Invalid session');
    end
else
    error('Invalid subjno');
end

marks = startP/1000;

% ����չʾ-��չʾ�ض�megͨ��
yrangeEMG = 200;
yrangeEEG = 100;
t = 0.001:0.001:length(EMGData(:,1))/1000;
close all
figure(1)
hold on
for i=1:8
    %if i == 2 || i == 3
    %i=9����Ҫɾ��emgͨ��
    if i == 9
        result = 0;
    else
        % ��������Ĵ���
        result = 1;% �������ʽ�ļ�����
    end
    plot(t, (EMGData(:,i)+yrangeEMG*(10-i))*result)
end
for i=1:16
    if i == 17 
        result = 1;
    else
        % ��������Ĵ���
        result = 0;% �������ʽ�ļ�����
    end
    plot(t, (EEGData(:,i)+yrangeEMG*10+50+yrangeEEG*(16-i))*result)
end
for i=1:length(marks)
    plot([marks(i) marks(i)], [-yrangeEMG yrangeEMG*10+100+yrangeEEG*16], 'k', 'LineWidth', 2)
end
hold off
xlim([0 152])
ylim([-yrangeEMG yrangeEMG*10+yrangeEEG*16+100])
legend('TA','PL','MG','LG','RF','VM','LBF','SEM',...
    'P4','CP2','FC5','C3','P3','C2','FC6','C4','CP6','F3','FC2','FC1', 'F4',...
    'CP5','C1','CP1')


%{
%% �������-�ֶ��ҹ���
splitidx = strfind(filepath, '/');
splitidx = splitidx(end);
folderpath = filepath(1:splitidx);
% filterfile = [subjno, '_', TMS, '_', 'filtered_', filepath(splitidx+1:end)];
filterfile = [subjno, '_', 'raw_processed_', filepath(splitidx+1:end)];
fid = fopen([folderpath filterfile], 'w');

save_idx = [];
%����1:1+TL_a�洢���ǵ�һ����ʼ�㵽�յ��ʵ��������
for i = 1:length(startP)
    if mod(i, 2) == 1
        TL = TL_a;%sit to stand
    else
        TL = TL_b;
    end
    save_idx = [save_idx startP(i):(startP(i)+TL)];
end
%������ʱ���
combineddata=[EMGData(save_idx,:) EEGData(save_idx,:)]';
fprintf(fid, '%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\r\n', combineddata);
%����ʱ���
% combineddata=[EMGData(startP:end,:) EEGData(startP:end,:) Timestamps(startP:end,:)]';
% fprintf(fid, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%d %d %.3f\r\n', combineddata);
fclose(fid);

%}