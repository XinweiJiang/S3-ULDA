function [ datas ] = makeaverge( data )
    [num,B]=size(data);
    for i =1:B
        oneline=data';
        oneline=oneline(i,:);
        averge=mean(oneline);
        linemax=max(oneline);
        linemin=min(oneline);
        oneline=oneline-ones(1,num)*linemin;
        oneline=oneline/(linemax-linemin);
        tempdata(i,:)=oneline;
    end
    datas=tempdata';
end

