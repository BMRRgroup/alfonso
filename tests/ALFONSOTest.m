classdef ALFONSOTest < matlab.unittest.TestCase
    %ALFONSOTest
    %   ALFONSO unit test class
    %
    
    properties
        %mrs
    end
    
    properties (TestParameter)
        ConstructorRawDataArg = {...
            './tests/data/philips/data/al_19042022_1501389_12_1_wip_te_steamV4_raw_012.data', ...
            %'./tests/data/philips/raw/al_19042022_1501389_12_1_wip_te_steamV4.raw', ...
            %'./tests/data/ge/P00000.7_00000000', ...
            %'./tests/data/philips/sdat/ALFONSO-TESTDATA_WIP_TE_STEAM_12_2_raw_act.SDAT', ...
             }
         RawDataFiles = {...
            './tests/data/philips/data/al_19042022_1441500_3_1_wip_steamV4_raw_003.data', ...
            './tests/data/philips/data/al_19042022_1444223_4_1_wip_pressV4_raw_004.data', ...
            './tests/data/philips/data/al_19042022_1501389_12_1_wip_te_steamV4_raw_012.data', ...
            %'./tests/data/philips/raw/al_19042022_1501389_12_1_wip_te_steamV4.raw', ...
            %'./tests/data/ge/P00000.7_00000000', ...
            %'./tests/data/philips/data/al_19042022_1445499_5_1_wip_te_steamV4_raw_005.data', ...
            %'./tests/data/philips/data/al_19042022_1448171_6_1_wip_te_pressV4_raw_006.data', ...
            %'./tests/data/philips/data/al_19042022_1450191_7_1_wip_shortie_steamV4_raw_007.data', ...
            %'./tests/data/philips/data/al_19042022_1453355_8_1_wip_ti_steamV4_raw_008.data', ...
            %'./tests/data/philips/sdat/ALFONSO-TESTDATA_WIP_TE_STEAM_12_2_raw_act.SDAT', ...
             }
         ReadDataReference = {...
             './tests/reference/data/philips/data/read_data_al_19042022_1441500_3_1_wip_steamV4_raw_003.mat', ...
             './tests/reference/data/philips/data/read_data_al_19042022_1444223_4_1_wip_pressV4_raw_004.mat', ...
             './tests/reference/data/philips/data/read_data_al_19042022_1501389_12_1_wip_te_steamV4_raw_012.mat', ...
             %'./tests/reference/data/philips/raw/read_data_al_19042022_1501389_12_1_wip_te_steamV4.mat', ...
             %'./tests/reference/data/ge/read_data_P00000.7_00000000.mat', ...
             }
    end
    
    methods(TestMethodSetup)
        %function createObj(testCase)
       %     testCase.mrs = ALFONSO();
       % end
    end
 
    methods(TestMethodTeardown)
        function closeFigures(testCase)
            close all
        end
    end
    
    methods (TestClassSetup)
        function addALFONSOClassToPath(testCase)
            p = path;
            testCase.addTeardown(@path,p)
            cd(fileparts(fileparts(mfilename('fullpath'))))
            addALFONSO2path();
            delete(['.' filesep 'tests' filesep 'temp' filesep '*'])
        end
    end
    
    methods (Test)
        % constructor tests / ALFONSOobj loading tests
        function testConstructor(testCase)
            obj = ALFONSO();
            % check properties of empty object
            testCase.verifyEqual(obj.data,[])
            testCase.verifyEqual(obj.dims,[])
            testCase.verifyEqual(obj.dims_siz,[])
            testCase.verifyClass(obj.scanparam, 'struct')
            testCase.verifyClass(obj.reconparam, 'struct')
            testCase.verifyClass(obj.quantparam, 'struct')
            testCase.verifyClass(obj.flags, 'struct')
            testCase.verifyEqual(obj.quant,[])
            testCase.verifyEqual(obj.cur_quant, 1)
            testCase.verifyClass(obj.version, 'char')
        end
        function testConstructorWithDataArg(testCase, ConstructorRawDataArg)
            obj = ALFONSO(ConstructorRawDataArg);
            % check properties of empty object
            testCase.verifyEqual(obj.data,[])
            testCase.verifyEqual(obj.dims,[])
            testCase.verifyEqual(obj.dims_siz,[])
            testCase.verifyClass(obj.scanparam, 'struct')
            testCase.verifyClass(obj.reconparam, 'struct')
            testCase.verifyClass(obj.quantparam, 'struct')
            testCase.verifyClass(obj.flags, 'struct')
            testCase.verifyEqual(obj.quant,[])
            testCase.verifyEqual(obj.cur_quant, 1)
            testCase.verifyClass(obj.version, 'char')
        end
        function testConstructorWithDataObjArg(testCase)
            ALFONSOobj_data = './tests/data/alfonso/al_19042022_1501389_12_1_wip_te_steamV4_raw_012.mat';
            obj = ALFONSO(ALFONSOobj_data);
            % check properties of empty object
            
            testCase.verifyClass(obj.data, 'double')
            testCase.verifySize(obj.data,[2048 4])
            testCase.verifyClass(obj.dims, 'cell')
            testCase.verifyEqual(obj.dims,{'x','TE'})
            testCase.verifyEqual(obj.dims_siz,[2048 4])
            testCase.verifyClass(obj.scanparam, 'struct')
            testCase.verifyClass(obj.reconparam, 'struct')
            testCase.verifyClass(obj.quantparam, 'struct')
            testCase.verifyClass(obj.flags, 'struct')
            testCase.verifyClass(obj.quant, 'cell')
            testCase.verifyClass(obj.version, 'char')
        end
        
        % test_example_processing
        function testSimpleProcessing(testCase, RawDataFiles)
            DIR_OUT = ['.' filesep 'tests' filesep 'temp' filesep];
            [~, fname] = fileparts(RawDataFiles);
            obj = ALFONSO(RawDataFiles);
            obj.read_data;
            obj.data_info;
            obj.coilcombination;
            obj.averaging;
            obj.phase_correction;
            obj.set_ref_freq('autoset-waterfat',1.3) % use methylene peak as reference
            obj.plot_dynSeries;
            obj.save_plots( DIR_OUT, {'jpg', 'png', 'fig'} )
            obj.save_obj(['testSimpleProcessing_' fname], DIR_OUT)
            testCase.verifyEqual(exist([DIR_OUT filesep 'testSimpleProcessing_' fname '.mat'],'file'),2)
        end
        
    end
    
    methods (Test, ParameterCombination = 'sequential')
        % read_dataTest
        function test_read_data(testCase, RawDataFiles, ReadDataReference)
            obj = ALFONSO(RawDataFiles);
            obj.read_data;
            
            obj_ref = ALFONSO(ReadDataReference);
            
            testCase.verifyEqual(obj.data,obj_ref.data)
            testCase.verifyEqual(obj.dims,obj_ref.dims)
            % check that at least all known params in the reference exist
            scanparams = fieldnames(obj_ref.scanparam);
            for iField = 1:length(scanparams)
                testCase.verifyEqual(obj.scanparam.(scanparams{iField}),obj_ref.scanparam.(scanparams{iField}))
            end
        end
    end
    
    methods (Test, ParameterCombination = 'pairwise')
        
    end
end

