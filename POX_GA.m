function [Chromosome] = POX_GA(T,Iterations,PopSize,Pc,Pm)
%% INPUT:
%T--input matrix:
    %Each instance consists of a line of description, a line containing the number of jobs and the number of machines, and then one line for each job,
    %listing the machine number and processing time for each step of the job. The machines are numbered starting with 0.
    % +++++++++++++++++++++++++++++
    %  Fisher and Thompson 6x6 instance, alternate name (mt06)
    %  6 6
    %  2  1  0  3  1  6  3  7  5  3  4  6
    %  1  8  2  5  4 10  5 10  0 10  3  4
    %  2  5  3  4  5  8  0  9  1  1  4  7
    %  1  5  0  5  2  5  3  3  4  8  5  9 
    %  2  9  1  3  4  5  5  4  0  3  3  1
    %  1  3  3  3  5  9  0 10  4  4  2  1
    %  +++++++++++++++++++++++++++++
%Iterations--The number of iterations of the genetic algorithm;
%PopSize--Population size in genetic algorithms,2*PopSize+1
%Pc--probability of crossover
%Pm--probability of mutation
%% OUTPUT
% Chromosome--The best Chromosome of the genetic algorithm
%% variable declaration
[num_of_jobs,number_of_machines]=size(T);                                  
number_of_machines = number_of_machines/2;
steps_of_job = number_of_machines;
PopSize = 2*PopSize+1;
Chromosome =[];
population =[];
len_of_chromosome = num_of_jobs*number_of_machines;
Performance1 =[];
Performance2 =[];
disp('begin interating ...')
%% Coding
%Coding is based on the step of the job
initial=[];
for i = 1:num_of_jobs
    for j = 1:number_of_machines
        initial=[initial i];
    end
end
%
%Generate population with chromosome containing random genes 
for i = 1:PopSize
    population(i,:)=initial(randperm(length(initial(:))));
end

%% Population iteration
Pfit_value = []; % probability of fitness value to be choosen in selection part
FITNESS = [];    % fitness values for population
BestChromosome =[]; 
for iterator = 1:Iterations
    %% fitness calculation
    for index=1:PopSize                         
        for gene = 1:len_of_chromosome
            chromosome(gene)=population(index,gene);                       % choose one chromosome from population
        end
        [FitnessValue] = FitnessCalculator(T,chromosome);                  % fitness calculation
        Pfit_value(index)=1/FitnessValue;                                  % The smaller the FitnessValue, 
        FITNESS(index)=FitnessValue;                                       % the larger the Pfit_value
    end
    BestFitness=min(FITNESS);                                              % find the best chromosome
    position=find(FITNESS==BestFitness);                                   % and the position,may be more than one
    for gene = 1:len_of_chromosome
        BestChromosome(gene)=population(position(1),gene);                 % choose one chromosome from population
    end
    
    %% Selection using Roulette Wheel
    Parent = [];   
    TotalFitness=sum(Pfit_value);                                           % Calculate the total fitness value - the denominator used in roulette  
    for i=1:PopSize                                                               % Calculate the probability of each individual being selected, 
        Pfit_value(i)=Pfit_value(i)/TotalFitness;                           % the molecule used in roulette
    end
                                                 
    
     % select (PopSize-1)/2
    SelectedChromosome=zeros(1,len_of_chromosome);

    for memeber=1:(PopSize-1)/2
        WheelSelectionNumber=rand;                                       
        Toltal = 0;
        for i=1:PopSize
            Toltal=Toltal+Pfit_value(i);          
            if (Toltal-Pfit_value(i))< WheelSelectionNumber && Toltal>=WheelSelectionNumber
                for gene = 1:len_of_chromosome
                    SelectedChromosome(gene)=population(i,gene);           % select one chromosome
                end
                break
            else    
                for gene = 1:len_of_chromosome
                    SelectedChromosome(gene)=population(i,gene);           % select current chromosome
                end  
            end
        end

        for gene = 1:len_of_chromosome
            Parent(memeber,gene)=SelectedChromosome(gene);
        end
    end 

   %% POX Crossover 
   
    Children_group1=[];
    for i=1:(PopSize-1)/2
        %Parent individuals are selected for crossover operation:
        %Parent1 is selected sequentially and Parent2 is selected randomly.
        index_parent2 = randi([1,(PopSize-1)/2]);
        for gene = 1:len_of_chromosome
            Parent1(gene)=Parent(i,gene);
            %Parent2(gene)=BestChromosome(gene);%Cross with best chromosome
            Parent2(gene)=Parent(index_parent2,gene);
        end
        
        Children1=zeros(1,len_of_chromosome);
        Children2=zeros(1,len_of_chromosome);
        if rand(1)<=Pc                                                     %The probability is used to determine whether crossover operations are required
            %Randomly divide the set of jobs {1,2,3...,n} into two non-empty sub-sets J1 and J2.
            num_J1 = randi([1,num_of_jobs]);   
            if num_J1==num_of_jobs
                num_J1 = fix(num_of_jobs/2);  
            end
            J = randperm(num_of_jobs);        
            J1 =J(1:num_J1);
           % J2 =J(num_J1+1:n); 
            %Copy the jobs that Parent1 contains in J1 to Children1,
            %and Parent2 contains in J1 to Children2, and keep them in place.
            for index = 1:num_J1
                %Look for the jobs that Parent1 and Parent2 contain in J1
                job = J1(index);
                for j = 1:len_of_chromosome
                    if job == Parent1(j)
                        Children1(j)=Parent1(j);
                        Parent1(j)=0;
                    end
                    if job == Parent2(j)
                        Children2(j)=Parent2(j);
                        Parent2(j)=0;
                    end   
                end  
               
            end
                               
            %Copy the jobs that Parent1 contains in J2 to Children2, 
            %and Parent2 contains in J2 to Children1 in their order.
            for index=1:len_of_chromosome
                if Parent1(index)~=0
                    for j=1:len_of_chromosome
                        if Children2(j)==0
                           Children2(j)=Parent1(index);
                           break;
                        end   
                    end 
                end
                if Parent2(index)~=0
                    for j=1:len_of_chromosome
                        if Children1(j)==0
                           Children1(j)=Parent2(index);
                           break;
                        end   
                    end
                end
            end   %POX Cross over         
        else  
        Children1 = Parent1;
        Children2 = Parent2;  
        end
        

%        condtion = rand(1);
        for gene = 1:len_of_chromosome
%             if condtion>0.5
%                 Children_group1(i, gene)=Children1(gene);
%             else
%                 Children_group1(i, gene)=Children2(gene);
%             end 
        Children_group1(2*i-1, gene)=Children1(gene);
        Children_group1(2*i, gene)=Children2(gene);
        end
    end
    
    
    %% Mutation 
    Children_group2=[];
    for i=1:(PopSize-1)
        for gene = 1:len_of_chromosome
            temp(gene)=Children_group1(i,gene);
        end
        if rand(1)<Pm
            for j=1:4
                pos1=randi([1,len_of_chromosome]);                         % Choose the sequence number of a gene to be mutated
                pos2=randi([1,len_of_chromosome]);                         % Choose the another sequence number of a gene to be mutated

                Gene=temp(pos1); 
                temp(pos1)=temp(pos2);
                temp(pos2)=Gene;
            end
        end
    
        for gene = 1:len_of_chromosome
            Children_group2(i,gene)=temp(gene);
        end
        
    end
    %�������
    
   %% rebuilt population
   % population=[ Children_group1;Children_group2;BestChromosome ];
    population=[ Children_group2;BestChromosome ];
    Chromosome = BestChromosome;
    Performance1(iterator) = BestFitness;
end
disp('BestCmax=')
disp(BestFitness);

figure(1);
plot(Performance1);




end

