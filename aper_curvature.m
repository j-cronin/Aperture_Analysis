% fileName = strcat('C:\Users\jcronin\Data\Subjects\fca96e\data\d7\fca96e_Aperture\Matlab\Aperture-9');
% load(fileName);
%%
figure;
y=Aper.data(150000:160000,1);
a = abs(diff(diff(y)));

b=power((1+power(diff(y),2)),3/2);
curv=a/b;

subplot(3,1,1)
plot(curv)

%% 
hold on
subplot(3,1,2)
% plot(diff(diff(Aper.data(150000:160000,1))), 'r')
axis([0 10000 0 1])

%%
hold on
subplot(3,1,3)
plot(Aper.data(150000:160000,1), 'b')
axis([0 10000 0 1])
