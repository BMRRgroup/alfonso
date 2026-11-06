function GitInfo = get_git_info(path)
    
    if exist(path, 'file') & ~isdir(path) % if path is a filename
        path = fileparts(path);
    end

    if ~exist(fullfile(path, '.git/'), 'dir') % move to parent directory
        uppath = fileparts(path);
        if strcmp(uppath, '/')          % prevent infinite recursion
            GitInfo = struct();
            return
        end
        GitInfo = get_GitInfo(uppath);
        return
    end
    
    try
        head = fileread(fullfile(path, '.git/HEAD'));
    catch
        GitInfo = struct();
        return
    end
    tmp = strsplit(head, '/');
    branch = char(strrep(tmp(end), char(10), '')); % remove newline character ^Z
    
    commit = 'unknown';
    % Try to read SHA1 from refs/heads file
    try
        sha1FilePath = fullfile(path, '.git', 'refs', 'heads', branch);
        if exist(sha1FilePath, 'file')
            SHA1file = fileread(sha1FilePath);
            commit = char(strrep(SHA1file, char(10), ''));
        end
    catch
        % refs/heads file read failed
    end
    
    % If commit not found, try packed-refs as fallback
    if strcmp(commit, 'unknown')
        try
            packedRefsPath = fullfile(path, '.git', 'packed-refs');
            if exist(packedRefsPath, 'file')
                packedRefsContent = fileread(packedRefsPath);
                refPattern = sprintf('refs/heads/%s', branch);
                lines = strsplit(packedRefsContent, '\n');
                for i = 1:length(lines)
                    line = strtrim(lines{i});
                    if endsWith(line, refPattern)
                        parts = strsplit(line);
                        if ~isempty(parts)
                            commit = parts{1};
                            break;
                        end
                    end
                end
            end
        catch
            % packed-refs read failed, continue with 'unknown'
        end
    end
    
    
    remote = '';
    url = '';
    config = fullfile(path, '.git/config');
    
    % Parse config file for remote and url
    if exist(config, 'file')
        fid = fopen(config);
        if fid ~= -1
            lines = {};
            while ~feof(fid)
                lines{end+1} = fgetl(fid);
            end
            fclose(fid);
            
            % Find remote for current branch
            for k = 1:length(lines)
                if isequal(lines{k}, sprintf('[branch "%s"]', branch))
                    m = k + 1;
                    while m <= length(lines) && ~startsWith(lines{m}, '[')
                        tokens = strsplit(strtrim(lines{m}));
                        if length(tokens) >= 3 && strcmp(tokens{1}, 'remote') && strcmp(tokens{2}, '=')
                            remote = char(tokens{3});
                            break;
                        end
                        m = m + 1;
                    end
                    break;
                end
            end
            
            % Find url for the remote
            for k = 1:length(lines)
                if isequal(lines{k}, sprintf('[remote "%s"]', remote))
                    m = k + 1;
                    while m <= length(lines) && ~startsWith(lines{m}, '[')
                        tokens = strsplit(strtrim(lines{m}));
                        if length(tokens) >= 3 && strcmp(tokens{1}, 'url') && strcmp(tokens{2}, '=')
                            url = char(tokens{3});
                            break;
                        end
                        m = m + 1;
                    end
                    break;
                end
            end
        end
    end
    
    GitInfo.branch = branch;
    GitInfo.commit = commit;
    GitInfo.remote = remote;
    GitInfo.url = url;

end