function [ alpha, beta, gamma, gof ] = least_squares_varpro_gss_cg( x, y, s, f_, lo, up, param, abs_err, varargin )
% least_squares_varpro_gss_cg
% Least squares estimation of generalized
% linear function with VARPRO and 1d golden section search
%
% IN:
%
% x                  = support points, size( x ) == [ 1, n ]
% y                  = data points, size( y ) == [ m, n ]
%
% s                  = inverse standard deviation, size( s ) = [ m, n ] 
%                      set to 1, if unknown ( s == [] )
%                      note, hoewever, that in models with offset the returned value of beta
%                      is to be interpreted as the offset in units of the
%                      standard deviation
%
% f_                 = @( x_, g_, p_ )                                   ( function )
% x_                 = actual value of x, size( x ) == [ m, n ]
% g_                 = actual value of real scalar gamma, size( g_ ) == [ m, n ]
% p_                 = some constant parameters ( if needed, otherwise p_ == [] )
%
% lo                 = lower bound of gamma
% up                 = upper bound of gamma
%
% param              = optional set of constant parameters ( needs to be understood by f )
%
% abs_err            = desired absulute accuracy of gamma
%
% varargin           = 'with offset': calculates model with offset
%                      'show progress': shows progress of iterations
%
% OUT:
%
% alpha, beta, gamma = ML estimators, size( ... ) == [ m, 1 ]
% gof                = chi2 / (n - #( fitpar ) )        (goodness of fit - should be close to one)
%
% (c) Carl Ganter 2015

offset_ = false;
debug_ = false;

nVarargs = length( varargin );

for i = 1 : nVarargs
	
	if ( isequal( varargin{ i }, 'with offset' ) )
		
		offset_ = true;
		
	elseif ( isequal( varargin{ i }, 'show progress' ) )
		
		debug_ = true;
		
	end
	
end

r = 0.5 * ( sqrt( 5 ) - 1 );                                               % golden ratio

[ m, n ] = size( y );

x_ = repmat( x, [ m 1 ] );                                                 % better for efficient function evaluation

if ( isempty( s ) )
	
	s = ones( size( y ) );
	
else
	
	y = y .* s;                                                            % rescaling with invese standard deviation

end

if ( offset_ )                                                             % model with offset

    s_y = dot( s, y, 2 );                                                  % < s, y >
    y_s = conj( s_y );                                                     % < y, s >
    s_s = dot( s, s, 2 );                                                  % < s, s >
    
end    
    
o = ones( size( y ) );

ga = lo .* o;                                                              % initialize lower boundary of gamma
gb = up .* o;                                                              % initialize upper boundary of gamma
gc = ga .* r + ( 1 - r ) .* gb;                                            % left intermediate point
gd = ( 1 - r ) .* ga + r .* gb;                                            % right intermediate point

size(s);
size(x);
size(gc);
f = s .* f_( x_, gc, param );                                              % function value at gc

y_y = dot( y, y, 2 );                                                      % < y, y >       (needed for goodness of fit)
f_y = dot( f, y, 2 );                                                      % < f, y >
y_f = conj( f_y );                                                         % < y, f >
f_f = dot( f, f, 2 );                                                      % < f, f >

if ( offset_ )                                                             % model with offset
    
    f_s = dot( f, s, 2 );                                                  % < f, s >
    s_f = conj( f_s );                                                     % < s, f >
    
    chi2_c = real( ( ...                                                   % chi^2 at gc
        2 .* real( y_f .* f_s .* s_y ) ...
        - f_f .* s_y .* y_s ...
        - s_s .* f_y .* y_f ...
        ) ./ ( ...
        f_f .* s_s - f_s .* s_f ...
        ) );
    
else                                                                       % model without offset
    
    chi2_c = ...                                                           % chi^2 at gc
        - real( f_y .* y_f ./ f_f );
    
end

f = s .* f_( x_, gd, param );                                              % function value at gd

f_y = dot( f, y, 2 );                                                      % < f, y >
y_f = conj( f_y );                                                         % < y, f >
f_f = dot( f, f, 2 );                                                      % < f, f >

if ( offset_ )                                                             % model with offset
    
    f_s = dot( f, s, 2 );                                                  % < f, s >
    s_f = conj( f_s );                                                     % < s, f >
    
    chi2_d = real( ( ...                                                   % chi^2 at gd
        2 .* real( y_f .* f_s .* s_y ) ...
        - f_f .* s_y .* y_s ...
        - s_s .* f_y .* y_f ...
        ) ./ ( ...
        f_f .* s_s - f_s .* s_f ...
        ) );
    
else                                                                       % model without offset
    
    chi2_d = ...                                                           % chi^2 at gd
        - real( f_y .* y_f ./ f_f );
    
end

cld = chi2_c < chi2_d;                                                     % mask for chi^2( gc ) < chi^2( gd )

i = 0;                                                                     % initialize index

while ( max( gd( : ) - gc( : ) ) > abs_err )                               % loop until accuracy is reached
    
    i = i + 1;                                                             % increment index

	if ( debug_ )
	
		fprintf( 1, '%d\t%f\n', i, max( gd( : ) - gc( : ) ) );             % show progress
    
	end
                                                                           % chi2_c < chi2_d: minimimum between ga and gd
    gb( cld, : ) = gd( cld, : );                                           % gd -> gb
    gd( cld, : ) = gc( cld, : );                                           % gc -> gd
    chi2_d( cld ) = chi2_c( cld );                                         % chi2_c -> chi2_d
    gc( cld, : ) = r * ga( cld, : ) + ( 1-r ) * gb( cld, : );              % new gc
    
                                                                           % chi2_c >= chi2_d: minimimum between gc and gb
    ga( ~cld, : ) = gc( ~cld, : );                                         % gc -> ga
    gc( ~cld, : ) = gd( ~cld, : );                                         % gd -> gc
    chi2_c( ~cld ) = chi2_d( ~cld );                                       % chi2_d -> chi2_c
    gd( ~cld, : ) = ( 1-r ) * ga( ~cld, : ) + r * gb( ~cld, : );           % new gd
    
    f( cld, : ) = s( cld, : ) .* ...
		f_( x_( cld, : ), gc( cld, : ), param );                           % function value at new gc
    f( ~cld, : ) = s( ~cld, : ) .* ...
		f_( x_( ~cld, : ), gd( ~cld, : ), param );                         % function value at new gd
    
    f_y = dot( f, y, 2 );                                                  % < f, y >
    y_f = conj( f_y );                                                     % < y, f >
    f_f = dot( f, f, 2 );                                                  % < f, f >

    if ( offset_ )                                                          % model with offset
        
        f_s = dot( f, s, 2 );                                              % < f, s >
        s_f = conj( f_s );                                                 % < s, f >
        
        chi2 = real( ( ...                                                 % new chi^2
            2 .* real( y_f .* f_s .* s_y ) ...
            - f_f .* s_y .* y_s ...
            - s_s .* f_y .* y_f ...
            ) ./ ( ...
            f_f .* s_s - f_s .* s_f ...
            ) );
        
    else                                                                   % model without offset
        
        chi2 = ...                                                         % new chi^2
            - real( f_y .* y_f ./ f_f );
        
    end
    
    chi2_c( cld ) = chi2( cld );                                           % chi2 -> chi2_c
    chi2_d( ~cld ) = chi2( ~cld );                                         % chi2 -> chi2_d
    
    cld = chi2_c < chi2_d;                                                 % update mask for chi^2( gc ) < chi^2( gd )
    
end % while

gamma = gc;                                                                % calculate optimal gamma
gamma( ~cld, : ) = gd( ~cld, : );

f = s .* f_( x_, gamma, param );                                           % function value at optimal gamma

gamma = gamma( :, 1 );                                                     % eliminate redundancy

f_y = dot( f, y, 2 );                                                      % < f, y >
f_f = dot( f, f, 2 );                                                      % < f, f >

if ( offset_ )                                                             % model with offset
    
    f_s = dot( f, s, 2 );                                                  % < f, s >
    s_f = conj( f_s );                                                     % < s, f >
    
    alpha = ( s_s .* f_y - f_s .* s_y ) ./ ...                             % calculate alpha
        ( f_f .* s_s - f_s .* s_f );

    beta = ( f_f .* s_y - s_f .* f_y ) ./ ...                              % calculate beta
        ( f_f .* s_s - f_s .* s_f );

	gof = real( y_y + alpha .* conj(alpha) .* f_f + ...
		beta .* conj(beta) .* s_s - ...
		2 .* ( alpha .* y_f + beta .* y_s - conj(alpha) .* beta .* f_s ) ) ...
		./ double( n - 5 );
	
else                                                                       % model without offset
    
    alpha = f_y ./ f_f;                                                    % calculate alpha

    beta = [];                                                             % no beta without offset

	gof = real( y_y + alpha .* conj(alpha) .* f_f - ...
		2 .* alpha .* y_f ) ...
		./ double( n - 3);

end

end
