function [xax,yax,zax,xunits,yunits] = roms_var_grid(fname,varname)
    
    warning off;
    
    if strcmp(varname,'pv')
        pos = 'p';
    else
        grid = roms_get_grid(fname,fname,0,1);

        % from John Wilkin's roms_islice.m
        % determine where on the C-grid these values lie 
        varcoords = nc_attget(fname,varname,'coordinates');
        if ~isempty(strfind(varcoords,'_u'))
          pos = 'u';
        elseif ~isempty(strfind(varcoords,'_v'))
          pos = 'v';
        elseif ~isempty(strfind(varcoords,'_w'))
          pos = 'w';
        elseif ~isempty(strfind(varcoords,'_rho'))
          pos = 'r'; % rho
        else
          error('Unable to parse the coordinates variables to know where the data fall on C-grid')
        end
    end

    switch pos
        case 'u'
            xax = grid.lon_u(1,:)';
            yax = grid.lat_u(:,1)';
            zax = grid.z_u(:,1,1);
            
            xunits = ncreadatt(fname,'x_u','units');
            yunits = ncreadatt(fname,'y_u','units'); 
            
        case 'v'
            xax = grid.lon_v(1,:)';
            yax = grid.lat_v(:,1)';
            zax = grid.z_v(:,1,1);
            
            xunits = ncreadatt(fname,'x_v','units');
            yunits = ncreadatt(fname,'y_v','units'); 
            
        case 'w'
            xax = grid.lon_rho(1,:)';
            yax = grid.lat_rho(:,1)';
            zax = grid.z_w(:,1,1);
            xunits = ncreadatt(fname,'x_rho','units');
            yunits = ncreadatt(fname,'y_rho','units'); 

        case 'r'
            xax = grid.lon_rho(1,:)';
            yax = grid.lat_rho(:,1)';
            
            if strcmp(varname, 'zeta');
                zax = [];
            else
                zax = grid.z_r(:,1,1);
            end
            xunits = ncreadatt(fname,'x_rho','units');
            yunits = ncreadatt(fname,'y_rho','units'); 
        
        case 'p'
            xax = ncread(fname,'x_pv');
            yax = ncread(fname,'y_pv');
            zax = ncread(fname,'z_pv');
            xunits = ncreadatt(fname,'x_pv','units');
            yunits = ncreadatt(fname,'y_pv','units');    
    end
    
    warning on;