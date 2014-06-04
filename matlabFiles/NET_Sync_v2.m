function [data] = NET_Sync_v2(host,port,command,type)
data = ' ';

if strcmpi(type,'Serial')
%     client = serial(host);
%     set(client, 'BaudRate', 19200, 'StopBits', 1);
%     set(client, 'Terminator', 'LF', 'Parity', 'none');
%     set(client, 'FlowControl', 'none');
%     
%     fopen(client);
% %     get(client,'Status')
%     
%     set(client, 'ReadAsyncMode','continuous');
%     fprintf(client, command);
%     data = fscanf(client);
% 
%     flushinput(client);
%     fclose(client);
%     delete(client);
%     clear client

    fprintf(port, command);
    data = fscanf(port);
    flushinput(port);

elseif strcmpi(type,'Ethernet')
    import System.*
    import System.Net.Sockets.*
    import System.IO.*
    
    client = TcpClient(host,port);
    
    s = client.GetStream();
    sr = StreamReader(s);
    sw = StreamWriter(s);
    sw.AutoFlush = true;
    sw.WriteLine(command);
    data = char(sr.ReadLine());
    client.Close();
    delete(client);
    clear client;
end
