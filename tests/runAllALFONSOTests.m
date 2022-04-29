%% Run all ALFONSO tests located under ./tests/
% Helper to run all exisiting tests located under ./tests/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Created:	Apr 22, 2022
%
% Revisions:    0.1 (Apr 22, 2022)
%					Initial version.
%
% Authors: 
%
%   stefan.ruschke@tum.de
% 
% --------------------------------
%
% Body Magnetic Resonance Research Group
% Department of Diagnostic and Interventional Radiology
% Technical University of Munich
% Klinikum rechts der Isar
% 22 Ismaninger St., 81675 Munich
% 
% https://www.bmrr.de
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TESTS_DIR = fileparts(mfilename('fullpath'));

addpath(genpath(TESTS_DIR))

import matlab.unittest.TestRunner
import matlab.unittest.Verbosity
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.XMLPlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat
import matlab.unittest.TestSuite;

suite = TestSuite.fromFolder(TESTS_DIR, 'IncludingSubfolders', true); 

runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);

mkdir('tests/code-coverage');
mkdir('tests/results');

runner.addPlugin(XMLPlugin.producingJUnitFormat('tests/results/results.xml'));
runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFolder(TESTS_DIR, 'Producing', CoberturaFormat('tests/code-coverage/coverage.xml'), 'IncludingSubfolders', true));

results = runner.run(suite);

disp('================================================================================================================')
disp('Results')
disp('================================================================================================================')
disp(table(results))
disp('================================================================================================================')

assert(~isempty(results), "no tests found")

if ~verLessThan('matlab', '9.8')
    % assertSuccess available since R2020a
    assertSuccess(results)
end