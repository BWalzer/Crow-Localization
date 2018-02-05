% %% ***************** Crow Auto Detection ******************
                        %Derek Flett
close all
clear all

%%%
%Import File
[FileName1,PathName] = uigetfile('C:\Kraken\Crow-Localization\*.wav','Select the first file');
[wave,fs] = audioread(FileName1); 

L = length(wave) ;
NFFT = L;
OutputfileName = 'Text'; 

%Creating Text file to store vital information for later analysis 
 fileName1=[OutputfileName,'.txt']; % Choose different extension if you like.
 % open a file for writing
 fid = fopen(fileName1, 'wt'); 
 if fid == -1
   error('Cannot open file: %s', fileName1); 
 end
 
%Uncomment to play unfiltered sound

% pOrig = audioplayer(wave,fs);
% pOrig.play;

t=0:1/fs:(length(wave)-1)/fs; % and get sampling frequency */
F = linspace(0,fs,NFFT);
soundData(:,2) = wave(:,2);
soundData(:,1) = t;
soundDatafft = fft(wave(:,2),NFFT);

%Plotting both channels pre-filtering
% figure('name','Pre and Post Filterd Sound','numbertitle','off')
% subplot(4,1,1)
figure (1)
          plot(t,wave(:,2))
          title('PreFiltered Channel One');
          ylabel('Amplitude');
          xlabel('Time (in seconds)');
%           
% subplot(4,1,2)
%           plot(F(1:NFFT/2+1),abs(soundDatafft(1:NFFT/2+1,1)))
%           title('PreFiltered FFT');
%           ylabel('Spectrum');
%           xlabel('Freq (in Hz)');
% %           
         
          
%Filtering out anything below 500 hz and above 2000 hz (subject to change)
%Design a bandpass filter that filters out between 500 to 2000 Hz
n = 7;
beginFreq = 500 / (fs/2);
endFreq = 2500/ (fs/2);
[b,a] = butter(n, [beginFreq, endFreq], 'bandpass');

% Filter the signal
fOut = filter(b, a, wave);


% Uncomment to play the filtered sound clip
% 

%Uncomment to play the filtered sound clip


%  p = audioplayer(fOut,fs);
% p.play;

%Storing Filtered sound file into new array 'wave2'
wave2 = fOut;          
soundData2 = zeros(length(wave),2);
soundData2(:,2) = wave2(:,2);
soundData2(:,1) = 1:1:L;
soundData2fft = fft(wave2(:,2),NFFT);
% subplot(4,1,3)
figure (2)
          plot(t,wave2(:,1))
          title('PostFiltered Channel One');
          ylabel('Filtered Amplitude');
          xlabel('Time (in seconds)');
% subplot(4,1,4)
%           plot(F(1:NFFT/2+1),abs(soundData2fft(1:NFFT/2+1,1)))
%           title('PostFiltered FFT');
%           ylabel('Filtered Spectrum');
%           xlabel('Freq (in Hz)');
%           
% figure('name','Sound Wave','numbertitle','off')
%           plot(t,wave2(:,2))
%           title('PostFiltered Channel One');
%           ylabel('Amplitude');
%           xlabel('Time (in seconds)');
          
% figure('name','Pre-Filtered Audio','numbertitle','off')
% subplot(4,1,1)
%           plot(t,wave(:,2))
%           title('PreFiltered Channel One');
%           ylabel('Amplitude');
%           xlabel('Time (in seconds)');
% figure('name','Post-Filtered Audio','numbertitle','off')   
%           plot(t,wave2(:,1))
%           title('PostFiltered Channel One');
%           ylabel('Filtered Amplitude');
%           xlabel('Time (in seconds)');          
%  


% 
% Nfft = 256;    win_size = 125;    ovlap = 0.90;
% [~,FFM_1,TTM_1,PM_1] = spectrogram(wave2,hanning(win_size),round(ovlap*win_size),Nfft,fs);
% imagesc(TTM_1,FFM_1(1:Nfft/2+1)/1000,10*log10(PM_1(1:Nfft/2+1,:))/10e-6);axis xy;colormap(jet)          
%% *****************  Caculating and Plotting Energy  *********************
tic;

%%Sum of energy Graph
timeStep = 0.1; 
steps = timeStep/(1/fs);

%Constants to find peaks in data 
%minEnergy is the minimum energy you want a possible crow call to be detected
numCalls = 10; %Number of calls you expect to hear 
SoundDetect = zeros(numCalls,4); 
energyData = zeros(L,1);




Total = L-steps;


% progressbar % Create figure and set starting time 
for i = 1:Total
    energyData(i) = sum(wave2(i:i+steps,2).^2);
%     progressbar(i/Total)
end
% toc;



%% ***************** Detecting and Saving Possible Calls*******************


%Detecting Peaks and the time they appear
minEnergy = 15;%minEnergy is the minimum energy you want a possible crow call to be detected
numCall = 70; %Number of calls you expect to encounter
SoundDetect = zeros(numCall,3);
ind = 1;


spaceSize = 3.00; %m
maxTime = (sqrt(spaceSize.^2+spaceSize.^2))/340;  %units seconds
maxIndex = floor(maxTime*fs);
Start_Stop = zeros(numCall,2);
% TH is the discussed "Thershold", or number of sames that the energy in
% increasing,
TH = fs*0.1;


conseq = 0;
ind3 = 1;
for i = 1:L
    if energyData(i) > minEnergy
        conseq = conseq +1;
            if conseq == 1 %Start of a possible call, having just passed the noise threshhold
                 Start_Stop(ind3,1) = i; %sample at which the sound occured
            end   
    else 
        if conseq > TH 
             Start_Stop(ind3,2) = i;
             [maxx,indx] = max(energyData(Start_Stop(ind3,1):Start_Stop(ind3,2)));
            SoundDetect(ind3,2) = maxx; %Energy of the sound
            SoundDetect(ind3,1) = indx+i-conseq-2;
            ind3 = ind3 + 1;
            conseq = 0;
        else 
            conseq = 0;
        end         
    end
end




%Theshhold Calulating 


%Plotting Energy vs Time
figure('name','Energy of Filtered Wave','numbertitle','off')
plot(1:L,energyData,'k');
          xlabel('Time');
          ylabel('Energy');
          title('Energy vs Time');
 hold on

          
 for i = 1:length(SoundDetect)
     if ((SoundDetect(i,1) ~= 0) && (SoundDetect(i,2) ~= 0))
          plot(SoundDetect(i,1),SoundDetect(i,2),'b*')
          plot(Start_Stop(i,1):SoundDetect(i,1),energyData(Start_Stop(i,1):SoundDetect(i,1)),'b')
     end
 end

line([1 L],[minEnergy minEnergy],'LineWidth',1)

 hold off
 
% %  Printing Relevant Segments of the entire sound file to a new text file to
% %  be later used by the User Interface in selecting which parts are to be
% %  anaylized by Crow Localization
% %  for i = 1:length(Start_Stop)
% %      if ((Start_Stop(i,1) ~= 0) && (Start_Stop(i,2) ~= 0)) 
% %               fprintf(fid,'%g\t',Start_Stop(i,:));
% %               fprintf(fid,'\n'); 
% %      end
% %  end
% %  
% %  
% %      fprintf(fid,'\n');
% %  fclose(fid);
% %  
% % % end
% % 
% %      
% %      


 