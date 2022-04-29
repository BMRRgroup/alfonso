classdef addALFONSO2pathTest < matlab.unittest.TestCase
    %addALFONSO2pathTest
    %   addALFONSO2path unit test class
    %   Currently this tests calls addALFONSO2path and checks if some
    %   predefined classess and functions are within the matlab path. 
    
    properties 
    end
    
    properties (TestParameter)
        % add matlab classes and functions to look out for, idealy from 
        % different sub directories / git submodules
        ClassesToFind = {...
            'ALFONSO', ...
            'IniConfig'
            }
        FunctionsToFind = {...
            'chebfun', ...
            'dimfun', ...
            'ensure_col', ...
            'ensure_row', ...
            'fhnd', ...
            'get_gitinfo', ...
            'GetFullPath', ...
            'io_loadspec_GE', ...
            'loadjson', ...
            'm2docgen', ...
            'matlab2tikz', ...
            'read_PHILIPS_datalist' ...
            'to_col', ...
            'to_row'
            } 
    end
    
    methods (TestClassSetup)
        function goto_root_dir(testCase)
            cd(fileparts(fileparts(mfilename('fullpath'))))
        end
    end
    
    methods (Test)
        function find_addALFONSO2path(testCase)
            testCase.verifyEqual(exist('addALFONSO2path','file'),2);
        end
        function test_findClasses(testCase, ClassesToFind)
            addALFONSO2path();
            % test if some of the functions are in the path now
            testCase.verifyEqual(exist(ClassesToFind,'class'),8);
        end
        function test_findFunctions(testCase, FunctionsToFind)
            addALFONSO2path();
            % find functions
            testCase.verifyEqual(exist(FunctionsToFind,'file'),2);
        end
    end
end