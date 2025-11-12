function [Padded_sweep] = ParamSweepGen_2(Candidates_sweep,Candidates_value,All_comb)
% Now This fuction allows to make a sweep of any arbitrarily big
% combination of parameter. beware of the number of simulations you ask
% for. It is also capable of handling specified combination of parameters,
% padding the single valued parameters.
%
% Now you can give arbitrary parameters to sweep over. You have to give the
% names of the parameters in a cell array

%Quite happy with this one.

%If all comb: easy. Just meshgrid the shit outta it. I think this is
%right. It seems it is.

TMP={};
if All_comb
    [TMP{1:length(Candidates_sweep)}]=ndgrid(Candidates_value{:});
    for i=1:length(Candidates_sweep)
        TMP{i}=TMP{i}(:);
    end
    Padded_sweep=cell(length(TMP{1}),length(TMP));
    for i=1:length(TMP{1})
        for j=1:length(TMP)
            Padded_sweep{i,j}=TMP{j}{i};
        end
    end
elseif ~All_comb
    %If specified combs:
    
    numelem=[];
    for i=1:length(Candidates_sweep)
        numelem(i)=numel(Candidates_value{i});
    end
    
    MeshGridVars=Candidates_sweep(numelem>1);
    
    %Is numelem the same for every variable?
    numelem_unique=sort(unique(numelem));
    %Si hay más de dos números distintos de numelems: incompatible.
    %Si hay justo dos, y el más pequeño NO es 1, entones casca. Si
    %solo 1, entonces bien.
    if or(numel(numelem_unique)>2,and(numel(numelem_unique)==2,numelem_unique(1)~=1))
        disp('Error: For specified combinations all given vectors must be same length')
        return
    end
    
    if ~isempty(MeshGridVars) %Algún coso con más de una entrada.
        Padded_sweep=cell(max(numelem),length(Candidates_sweep));
        %Detect which ones are the given vectors and populate padded
        %cell
        ind2pad=1:length(Candidates_sweep);
        for i=1:length(MeshGridVars)
            ind=find(strcmp(Candidates_sweep,MeshGridVars{i}));
            ind2pad(ind2pad==ind)=[];
            tmp=Candidates_value{ind};
            for j=1:max(numelem)
                Padded_sweep{j,ind}=tmp{j};
            end
        end
        %Detect the non vectors and pad them:stored in ind2pad.
        for i=1:length(ind2pad)
            tmp=Candidates_value{ind2pad(i)};
            for j=1:max(numelem)
                Padded_sweep{j,ind2pad(i)}=tmp{1};
            end
        end
    elseif numelem_unique==1 %Una sola combinación especificada.
        Padded_sweep=cell(1,length(Candidates_sweep));
        for i=1:length(Candidates_sweep)
            Padded_sweep{1,i}=Candidates_value{i}{1};
        end
        
    end
    
end



