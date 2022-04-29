function [ onepart ] = getonepart( data,labels,knear,dims,i)

        Num=size(data .Y,2);
        [m,n]=size(labels);
        onelabelleft=[];
        onelabelright=[];
        onelabeltop=[];
        onelabelbutton=[];
        nearlabel=[];
        onelabel=data.cor{1,i};
        [onelabel_num,~]=size(onelabel);
        nowlabel=data.nowlabel{1,i};
        for o=1:onelabel_num
            onelabelright(o,:)=onelabel(o,:)+[1,0];
            onelabelleft(o,:)=onelabel(o,:)+[-1,0];
            onelabeltop(o,:)=onelabel(o,:)+[0,-1];
            onelabelbutton(o,:)=onelabel(o,:)+[0,1];
        end
        geshu=0;
        for o=1:onelabel_num
            if onelabelright(o,1)~=m+1
                rect=onelabelright(o,:);
                x=rect(1);
                y=rect(2);
                if labels(x,y)~=nowlabel
                   geshu=geshu+1;
                   nearlabel(geshu,1)=labels(x,y);
                end
            end
            if onelabelleft(o,1)~=0
                rect=onelabelleft(o,:);
                x=rect(1);
                y=rect(2);
                if labels(x,y)~=nowlabel
                   geshu=geshu+1;
                   nearlabel(geshu,1)=labels(x,y);
                end
            end
            if onelabeltop(o,2)~=0
                rect=onelabeltop(o,:);
                x=rect(1);
                y=rect(2);
                if labels(x,y)~=nowlabel
                   geshu=geshu+1;
                  nearlabel(geshu,1)=labels(x,y);
                end
            end
            if onelabelbutton(o,2)~=n+1
                rect=onelabelbutton(o,:);
                x=rect(1);
                y=rect(2);
                if labels(x,y)~=nowlabel
                   geshu=geshu+1;
                   nearlabel(geshu,1)=labels(x,y);
                end
            end
        end
        results.Y=cell(0,0);
        results.index=cell(0,0);
        results.index=cell(0,0);
        klabel=unique(nearlabel);
        [klabelnum,~]=size(klabel);
        Y=cell(1,klabelnum+1);
        index=cell(1,klabelnum+1);
        results.Y{1,1}=data.Y{1,i};
        results.index{1,1}=data.index{1,i};
        results.cor{1,1}=data.cor{1,i};
        X1=[];
        X2=[];
        Y=[];
        biaoqian=1;
        X1=cat(1,X1,results.Y{1,1});
        X2=cat(1,X2,findConstruct(results.Y{1,1}, results.cor{1,1},knear));
        A_PC=findConstruct(results.Y{1,1}, results.cor{1,1},knear);
        Y=cat(1,Y,ones(onelabel_num,1)*biaoqian);
        biaoqian=biaoqian+1;
%         disp(klabelnum);
        for k=1:klabelnum
            for nums=1:Num
                if klabel(k)==data.nowlabel{1,nums}
                   results.Y{1,k+1}=data.Y{1,nums};
                   results.index{1,k+1}=data.index{1,nums};
                   results.cor{1,k+1}=data.cor{1,nums};
                   X1=cat(1,X1,results.Y{1,k+1});
                   X2=cat(1,X2,findConstruct(results.Y{1,k+1}, results.cor{1,k+1},knear));
                   [biaoqiannum,~]=size(results.Y{1,k+1});
                   Y=cat(1,Y,ones(biaoqiannum,1)*biaoqian);
                   break;
                end
            end  
        end
        [V,~]=getneed2(X2',X1',Y,dims);
        onepart=A_PC*V;
end

