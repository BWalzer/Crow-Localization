n = 100000; 
progressbar % Create figure and set starting time 
x=1
T=n-300
for i = 1:n-300 
    x = x+1;
    progressbar(i/n-300)

end