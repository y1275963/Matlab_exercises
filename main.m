
%This is a mature work of nerual network and Generatic Algorithm

clear all;
clc;
load data input output;
pc = 0.25;
pm = 0.1;

sizepop = 10;
inputnum = 2;
hiddennum = 5;
outputnum = 1;
sizeall = inputnum*hiddennum + hiddennum*outputnum + hiddennum+ outputnum;
thebest = zeros(1,sizeall);
recoder = zeros(30,sizepop);
bound=[-3*ones(sizepop,1) 3*ones(sizepop,1)];

tknet = cell(sizepop,4);
newtknet = cell(sizepop,4);


input = input';
output = output';
array = randperm(2000);
[input_train,insed]= mapminmax(input(:,array(1:1900)));
[output_train,oused] = mapminmax(output(array(1:1900)));

input_test = mapminmax('apply',input(:,array(1901:2000)),insed);
% ouput_test = mapminmax('apply',output(array(1901:2000)),oused);



net = newff(input_train,output_train,5);

 for i = 1: sizepop
     netemp = newff(input_train,output_train,5);
     n1 = netemp.iw{1,1};
     n2 = netemp.lw{2,1};
     n3 = netemp.b{1};
     n4 = netemp.b{2};
     tknet{i,1} = [n1(:,1)' n1(:,2)' n2 n3' n4];
     fitemp = fitness(tknet{i,1},inputnum,hiddennum,outputnum,net,input_train,output_train);
     fit = 1/(fitemp+1);
     tknet{i,2} = fit;
     tknet{i,4} = i;     
 end
 
for jk = 1:50
     
     temp = cell2mat(tknet(:,2));
     all = sum(temp);
     
     for i = 1:sizepop
         tknet{i,3} = tknet{i,2}/all;
     end
     
     area = cell2mat(tknet(:,3));
     area = cumsum(area);
        
     for i = 1: sizepop
         seed = rand;
         nomin = find(area>seed,1,'first');
         newtknet(i,:) = tknet(nomin,:);
         newtknet{i,4} = i;
     end
     tknet = newtknet;
     
     test = [];
     
     for i = 1 : sizepop
         r =rand;
         if r < pc 
             test = [test;tknet(i,:)]; % Test is the poll of crossover
         end
     end
    [use,less] = size(test);
    for i = 1 :use
        if i ~= use 
            cutpoint = fix(1 + rand*sizeall);
            temp1 = test{i,1};
            temp2 = test{i+1,1};
            temp1(1,cutpoint:end) = temp2(1,cutpoint:end);
            test{i,1}=temp1;
        else
            cutpoint = fix(1 + rand*sizeall);
            temp1 = test{use,1};
            temp2 = test{1,1};
            temp1(1,cutpoint:end) = temp2(1,cutpoint:end);
            test{use,1}=temp1;
        end
    end
    
    if ~isempty(test)
        pointer = cell2mat(test(:,4));
        for i = 1 : length(pointer)
            tknet(pointer(i),:)=test(i,:);
        end
    end
    %Mutation
    
    len = fix(pm*sizeall*sizepop);
    
    for i = 1 : len
        candidate1 = fix(1+rand*sizepop);
        candidate2 = fix(1+rand*sizeall);
        
        temp = cell2mat(tknet(candidate1,1));

        r1 = rand;
        r2 = rand;
        
        if r1 > 0.5 
            temp(1,candidate2) =  temp(1,candidate2) + (temp(1,candidate2) - bound(candidate1,2))*fg(jk);
        else 
            temp(1,candidate2) = temp(1,candidate2) + (bound(candidate1,1)-temp(1,candidate2))*fg(jk);
        end
        
%         temp(1,candidate2) = rand;
        tknet(candidate1,1)={temp};
    end
    %Evaluation
    
    for i = 1:sizepop
        a = cell2mat(tknet(i,1));
        fittemp = fitness(a,inputnum,hiddennum,outputnum,net,input_train,output_train);
        fit = 1/(fittemp+1);
        tknet(i,2)={fit};
        recoder(jk,i)=fit;
        if fit >= max(max(recoder))   % This is a bug that I corrected
            thebest = a;
        end
    end 
end

w1 = thebest(1:inputnum*hiddennum);
b1 = thebest(1+inputnum*hiddennum:hiddennum+inputnum*hiddennum);
w2 = thebest(1+hiddennum+inputnum*hiddennum: hiddennum+inputnum*hiddennum + hiddennum*outputnum);
b2 = thebest(1+hiddennum+inputnum*hiddennum + hiddennum*outputnum:hiddennum+inputnum*hiddennum + hiddennum*outputnum+outputnum);


net.iw{1,1}=reshape(w1,hiddennum,inputnum);
net.lw{2,1}=reshape(w2,outputnum,hiddennum);
net.b{1}=reshape(b1,hiddennum,1);
net.b{2}=b2;

net.trainParam.epochs=100;
net.trainParam.lr = 0.1;
net.trainParam.goal = 0.00004;
net.trainParam.showWindow = 0;

net = train(net,input_train,output_train);

y = sim(net,input_test);







 


    
    
    
    
        
               
 
     
     
 
 
     