
row = 2; 
row = row-1;
%load('C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\apertureTask_ecb43e_20150406T145822_trial1.mat');

fileName = 'C:\Users\jcronin\Data\Subjects\ecb43e\d7\Aperture_ecb43e\apertureTask_ecb43e_20150406T145822_trial1.mat';
load(fileName);

fileToWrite = '';
names = strsplit(fileName, '\');
csvwrite(fileToWrite, names(1,length(names)), row, 2);

csvwrite(fileToWrite, file_to_load, row, 3);
% csvwrite(fileToWrite, names(1,length(names)), row, 4);
% csvwrite(fileToWrite, names(1,length(names)), row, 5);

csvwrite(fileToWrite, length_aperTask, row, 6);
csvwrite(fileToWrite, accuracy, row, 7);
csvwrite(fileToWrite, spaceTimeEnd, row, 8);
