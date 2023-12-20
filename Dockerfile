############ Streamlit BASE IMAGE ONLY Dockerfile ############
# Ubuntu 22.04 base with Python runtime and pyodbc to connect to SQL Server
FROM ubuntu:22.04

WORKDIR /data/python_with_git
# ADD requirements.txt .
ADD config.toml .
RUN mkdir ~/.streamlit
RUN cp /data/python_with_git/config.toml ~/.streamlit

# apt-get and system utilities
RUN apt-get update && apt-get install -y \
	curl apt-utils apt-transport-https debconf-utils gcc build-essential g++ unixodbc-dev

ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install Neccessary for ubuntu package
RUN apt-get update -y && \
    apt-get install -y python3.11 python3-pip python3-dev default-libmysqlclient-dev build-essential pkg-config openssh-server vim git-all iputils-ping traceroute

# RUN pip3 install python modules
RUN pip3 install pandas
RUN pip3 install psycopg2-binary
RUN pip3 install SQLAlchemy
RUN pip3 install jupyterlab
RUN pip3 install plotly
RUN pip3 install streamlit
RUN pip3 install streamlit-aggrid
RUN pip3 install jupyter_contrib_nbextensions

# Set the root password for the SSH server (CHANGE THIS PASSWORD!)
RUN echo 'root:Dataeng123!' | chpasswd

#### -- For setting SSH with Public key -- ####
# Permit root login via SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Enable password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

### Start Command - Enable passwordless authentication with public key ###
RUN sed -i 's/#HostKey \/etc\/ssh\/ssh_host_rsa_key/HostKey \/etc\/ssh\/ssh_host_rsa_key/' /etc/ssh/sshd_config
RUN sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/' /etc/ssh/sshd_config
RUN sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ed25519_key/HostKey \/etc\/ssh\/ssh_host_ed25519_key/' /etc/ssh/sshd_config

RUN sed -i 's/#AuthorizedKeysFile	.ssh\/authorized_keys .ssh\/authorized_keys2/#AuthorizedKeysFile	.ssh\/authorized_keys .ssh\/authorized_keys2\
AuthorizedKeysFile	.ssh\/authorized_keys/' /etc/ssh/sshd_config

RUN sed -i 's/#PermitEmptyPasswords no/#PermitEmptyPasswords no\
PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN sed -i 's/AcceptEnv LANG LC_*/AcceptEnv LANG LC_*\
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES\
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT\
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE\
AcceptEnv XMODIFIERS/' /etc/ssh/sshd_config

RUN sed -i 's/#	ForceCommand cvs server/#	ForceCommand cvs server\
Match group sftp\
ChrootDirectory \/home\
X11Forwarding no\
AllowTcpForwarding no\
ForceCommand internal-sftp/' /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
### Start Command - Enable passwordless authentication with public key ###


# Expose Port for SSH, JupyterLab, Streamlit (optional, change if needed)
EXPOSE 22
EXPOSE 8888
EXPOSE 8501

## For start the SSHD Service
CMD ["nohup","/usr/sbin/sshd", "-D","&"]
RUN sleep 5
## For autto Start Jupyter Service
CMD ["nohup","jupyter", "lab","--ip='0.0.0.0'","--port=8888","no-browser","--allow-root","--notebook-dir=/data","&"]
RUN sleep 5
## For autto Start Streamlit Service
CMD ["nohup","streamlit", "run", "homepage.py", "--server.port=8501", "--server.address=0.0.0.0","&"]



	
### Packages need to install for connect MS-SQL Server
# RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc
# RUN curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
# RUN apt-get update
# RUN ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated msodbcsql18
# RUN ACCEPT_EULA=Y apt-get install -y --allow-unauthenticated mssql-tools
# RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
# RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

### install necessary locales, this prevents any locale errors related to Microsoft packages
#RUN apt-get update && apt-get install -y locales \
#    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
#    && locale-gen

### For connecting Database MS-SQL Server version 2016
# RUN sed -i 's/CipherString = DEFAULT:@SECLEVEL=2/CipherString = DEFAULT:@SECLEVEL=0/g' /etc/ssl/openssl.cnf
# RUN echo "MinProtocol = TLSv1.1" >> /etc/ssl/openssl.cnf