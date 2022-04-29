classdef examplesTest < matlab.unittest.TestCase
    %examplesTest
    %   examples unit test class for the ALFONSO examples which can be 
    %   found under ./examples 
    
    properties 
    end
    
    properties (TestParameter)
        % add examples to test
        ExamplesToTest = {...
            'example_processing', ...
            'example_quantification', ...
            'example_visualization', ...
        }
    
    end
    
    methods (TestClassSetup)
        function setup(testCase)
            cd(fileparts(fileparts(mfilename('fullpath'))))
            addALFONSO2path();
            delete(['.' filesep 'examples' filesep 'temp' filesep '*'])
        end
    end
    
    methods(TestMethodTeardown)
        function closeFigures(testCase)
            close all;
        end
    end

    
    methods (Test)
        
        function find_examples(testCase, ExamplesToTest)
            testCase.verifyEqual(exist([pwd filesep 'examples' filesep ExamplesToTest],'file'),2);
        end
        
        function test_examples(testCase, ExamplesToTest)
            fh = str2func(ExamplesToTest);
            fh();
            %close all;
        end
    end
end