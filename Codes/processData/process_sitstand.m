clc
clear all

%{
    ���ļ����������ݽ���Ԥ����
        - �������ݵ�eeglab�����а����缫λ����Ϣ��Ԫ���ݣ��¼���Ϣ
        - �����ݽ����˲�
        - ...δ�����
%}

eeglab;
EEG.etc.eeglabvers = '2023.1'; % this tracks which version of EEGLAB is being used, you may ignore it
motion = 'sitstand';
dir = 'D:/Documents/Peng/EGG/Datasets';

% ����subj1_raw_processed_s01��chanlocs��events_info�����EMGͨ����ǩ

subj_id = 3;

for k=0:3
    % if k == 1
    %     continue; % ����������ʵ��
    % end

    subj_no = strcat('subj',[num2str(subj_id)]);
    session = strcat('week',[num2str(k)]);
    %txt_path = strcat(file_path{1},'/','subj',subj_num,'/sitstand/',[file_name '.txt']);
    file_path={strcat(dir,'/', subj_no, '/',motion) strcat(dir, '/',subj_no, '/',motion,'/','set')};

    % file path �Ƿ����
    if ~exist(file_path{1}, 'dir')
        mkdir(file_path{1}); % ��������ڣ������ļ���
    end
    if ~exist(file_path{2}, 'dir')
        mkdir(file_path{2}); % ��������ڣ������ļ���
    end
    fprintf("file_path1: %s\n",file_path{1});
    fprintf("file_path2: %s\n",file_path{2});

    % �����˲�������������
    fname = strcat(subj_no,'_raw_processed_',session,'.txt');
    txt_path = strcat(file_path{1},'/',fname);
    fprintf("txt_path: %s\n",txt_path);

    % ����ͨ��λ���ļ�
    locs_path = strcat(dir,'/','code_locs/24eegemg_sitstand_locs.ced');
    fprintf("locs_path: %s\n",locs_path);

    % �����¼��ļ�
    events_fname = strcat(subj_no,'_',session,'_events_info.txt');
    events_path = fullfile(dir, subj_no, motion,'events_info',events_fname);%����Ҫ,'\',
    fprintf("events_path: %s\n",events_path);
    file_name = strcat(subj_no,'_',session,'_beforeInterpol');


    % �жϼ��ص��Ƿ����
    if ~exist(txt_path, 'file')
        error("�����ļ�·����Ч��%s", txt_path);
    end
    
    if ~exist(locs_path, 'file')
        error("ͨ��λ����Ϣ�ļ�·����Ч��%s", locs_path);
    end
    if ~exist(events_path, 'file')
        error('�Ҳ����¼��ļ�: %s', events_path);
    end

    %{
        ����EEG����
        dataformat: ascii # ����TXT��ʽ������
        nbchan: 0 # ��ʼͨ��������0��ʾ�Զ����
        data: txt_path # ���ݵ��ļ�λ��
        setname: filename # ����������ݼ����� 
        srate: 1000 # ������
        pnts: 0 # ������������0��ʾ�Զ����
        xmin: 0 # ������ʼʱ���
        chanlocs: locs_path # EEG �缫�ı�ǩ��λ����Ϣ
    %}
    EEG = pop_importdata('dataformat','ascii','nbchan',0,'data',txt_path,'setname',file_name,'srate',1000,'pnts',0,'xmin',0,'chanlocs',locs_path);


    %  ��ǰ8��ͨ���������޸�ΪEMG�� ԭʼ�������ǰ8����EMG����
    EEG=pop_chanedit(EEG, ...
        'changefield',{1,'type','EMG'}, ...
        'changefield',{2,'type','EMG'}, ...
        'changefield',{3,'type','EMG'}, ...
        'changefield',{4,'type','EMG'}, ...
        'changefield',{5,'type','EMG'}, ...
        'changefield',{6,'type','EMG'}, ...
        'changefield',{7,'type','EMG'}, ...
        'changefield',{8,'type','EMG'} ...
    );

    % �����¼���Ϣ
    EEG = pop_importevent( EEG, 'event',events_path,'fields',{'type','latency','duration'},'timeunit',NaN);

    % ������֤ EEG ���ݼ��������Ժ�һ����
    EEG = eeg_checkset( EEG );

    %����Ϊset
    EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',file_path{2});
end

%����������к���Ҫclear������



% ��_beforeInterpol�ֶ���ֵ����,ȥ������������ݶ�-ManuRej;
% ��ICA,�ǵ�ѡ��ͨ������EEG��-ICA;
% ��IClabel,�޳�����IC�õ�-preped;

% EMGӰ��ۿ�ʱ��
EEG_a = EEG; 
for i = 1:8
    EEG_a.data(i,:) = EEG_a.data(i,:)*0;
end
pop_eegplot( EEG_a, 1, 1, 1); 


% zhikanC3��
% EEG_a = EEG;
% for i = 1:22
%     if i == 10
%         continue;
%     end
%     EEG_a.data(i,:) = EEG_a.data(i,:)*0;
% end
% pop_eegplot( EEG_a, 1, 1, 1); 





% %����EMG    
% EEG_b = EEG;
% for i = 9:24
%     EEG_b.data(i,:) = EEG_b.data(i,:)*0;
% end
% pop_eegplot( EEG_b, 1, 1, 1); 


%����ʵ��
%{

% ����epochs
EEG_a = pop_epoch( EEG, {  'a'  }, [0         5.4], 'newname', 'subj1_s01_interpol epochs_a', 'epochinfo', 'yes');
EEG_b = pop_epoch( EEG, {  'b'  }, [0         3], 'newname', 'subj1_s01_interpol epochs_b', 'epochinfo', 'yes');
pop_eegplot( EEG_a, 1, 1, 1);

%%% �޳�����-����Ҫ����
to_delete = false(1, EEG.trials);  % ȫ����ʼ��Ϊfalse
to_delete([1]) = true;  % ����Ҫɾ����epoch������Ϊtrue
% ʹ��pop_select����ɾ��ָ��������epoch
EEG_a = pop_select(EEG_a, 'notrial', to_delete);
pop_eegplot( EEG_a, 1, 1, 1);

file_path={'D:\EEG\�������Ŀ\data_rename\subj1\sitstand' 'D:\EEG\�������Ŀ\data_rename\subj1\sitstand\epoch'};
file_name = 'subj1_s01_a';
EEG_a = pop_saveset( EEG_a, 'filename',[file_name '_Epo.set'],'filepath',file_path{2});


%%% b %%%
pop_eegplot( EEG_b, 1, 1, 1);

%%% �޳�����-����Ҫ����
to_delete = false(1, EEG.trials);  
to_delete([]) = true;  
EEG_b = pop_select(EEG_b, 'notrial', to_delete);
pop_eegplot( EEG_b, 1, 1, 1);

file_path={'D:\EEG\�������Ŀ\data_rename\subj1\sitstand' 'D:\EEG\�������Ŀ\data_rename\subj1\sitstand\epoch'};
file_name = 'subj1_s01_b';
EEG_b = pop_saveset( EEG_b, 'filename',[file_name '_Epo.set'],'filepath',file_path{2});

}%

% runICA
file_name = 'subj1_s01_a';
file_path={'D:\EEG\�������Ŀ\data_rename\subj1\sitstand\epoch' 'D:\EEG\�������Ŀ\data_rename\subj1\sitstand\ICA'};
EEG = pop_loadset('filename',[file_name  '_Epo.set'],'filepath',file_path{1});%����.set����

EEG = pop_select(EEG, 'channel', 'EEG');
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',14);%��Ϊ��ֵ��������
EEG = pop_iclabel(EEG, 'default');
EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %��������

%�޳�IC
EEG = pop_iclabel(EEG, 'default');
EEG = pop_subcomp( EEG, [4  7  8  9], 0);
EEG.setname='subj1_s01_a_preped';
%�����⡣
EEG = eeg_checkset( EEG );
file_path = 'D:\EEG\�������Ŀ\data_rename\subj1\sitstand\preped'
EEG = pop_saveset( EEG, 'filename',[file_name  '_preped.set'],'filepath',file_path); %��������












%{
file_path={'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\set' 'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\ICA'};
for i =1:6;%��Ҫ�޸�
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '.set'],'filepath',file_path{1});%����.set����
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');%runICA
    EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %��������
end
%}






%{
file_path={'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\EDF' 'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\set'};
for i=1:6%��Ҫ�޸�
    file_name=[num2str(i)];
    EEG = pop_biosig(strcat(file_path{1},'\',[file_name '.edf']) );
    EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'lookup','E:\\MATLAB���߰�\\eeglab12_0_2_6b\\plugins\\dipfit2.2\\standard_BESA\\standard-10-5-cap385.elp');
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'nochannel',{'HEO' 'VEO' 'Trigger' 'CB1' 'CB2'});
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 1, 1650, true, [], 1);%����֮ǰ�Ĳ����˲�
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [], 40, 166, 0, [], 1);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[file_name '.set'],'filepath',file_path{2});
    EEG = eeg_checkset( EEG );
end

%�ֶ�ȥ���Σ���ֵ����

%��ica

file_path={'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\set' 'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\ICA'};
for i =1:6;%��Ҫ�޸�
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '.set'],'filepath',file_path{1});%����.set����
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');%runICA
    EEG = pop_saveset( EEG, 'filename',[file_name  '_ICA.set'],'filepath',file_path{2}); %��������
end






%ת�ο�
file_path={'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\ICA' 'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\REF'};
for i =1:6;%��Ҫ�޸�
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '_ICA.set'],'filepath',file_path{1});%����.set����
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );%ȫ��ƽ���ο�
    EEG = pop_saveset( EEG, 'filename',[file_name  '_REF.set'],'filepath',file_path{2}); %��������
end





%�ֶ�

file_path={'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\REF' 'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\epoch'};
for i =1:6;%��Ҫ�޸�
    file_name=[num2str(i)];
    EEG = pop_loadset('filename',[file_name  '_REF.set'],'filepath',file_path{1});%����.set����
    EEG = pop_epoch( EEG, {  '2'  }, [-0.2         0.8], 'newname', 'EDF file resampled epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    EEG = pop_rmbase( EEG, [-200    0]);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[file_name  '_EPOCH.set'],'filepath',file_path{2}); %��������
end


%}


































%{
file_path={'D:\\EEG\\�������Ŀ\\data_rename' 'C:\Users\jd\Desktop\������ѵ��\Ԥ������\raw_data\set'};
i = 1;
k = 1;
subj_num =[num2str(i)];
session = [num2str(k)];
file_name = strcat('s0',session);
txt_path = strcat(file_path{1},'\','subj',subj_num,'\sitstand\',[file_name '.txt']);
EEG = pop_importdata('dataformat','ascii','nbchan',0,'data',txt_path,'setname','test_history','srate',1000,'pnts',0,'xmin',0,'chanlocs','D:\\EEG\\�������Ŀ\\data_rename\\code_locs\\32eegemg_sitstand_locs.ced');
%��EMGͨ����ӱ�ǩ
EEG=pop_chanedit(EEG, 'changefield',{1,'type','EMG'},'changefield',{2,'type','EMG'},'changefield',{3,'type','EMG'},'changefield',{4,'type','EMG'},'changefield',{5,'type','EMG'},'changefield',{6,'type','EMG'},'changefield',{7,'type','EMG'},'changefield',{8,'type','EMG'});
%}

    
%}

