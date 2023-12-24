############ Ubuntu + Python (Jupyter & Streamlit) Dockerfile ############
# Ubuntu 22.04
FROM ubuntu:22.04

### Create environment for Streamlit workdir
WORKDIR /data/ubuntu-python-streamlit
ADD config.toml .
RUN mkdir ~/.streamlit
RUN cp /data/ubuntu-python-streamlit/config.toml ~/.streamlit

### apt-get and system utilities
RUN apt-get update && apt-get install -y \
	curl apt-utils apt-transport-https debconf-utils gcc build-essential g++ unixodbc-dev

ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

### install Neccessary for ubuntu package
RUN apt-get update -y && \
    apt-get install -y python3.11 python3-pip python3-dev default-libmysqlclient-dev build-essential pkg-config openssh-server vim git-all iputils-ping traceroute

### RUN pip3 install python modules (it can be modified based on preferences)
RUN pip3 install pandas
RUN pip3 install psycopg2-binary
RUN pip3 install SQLAlchemy
RUN pip3 install plotly
RUN pip3 install streamlit
RUN pip3 install streamlit-aggrid

### Set the root password for the SSH server (CHANGE THIS PASSWORD!)
RUN echo 'root:Dataeng123!' | chpasswd

#### -- For configure SSH access with Public key -- ####
# 1- Permit root login via SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 2- Enable password authentication
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 3- Start Command - Enable passwordless authentication with public key ###
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
# 3- End Command - Enable passwordless authentication with public key ###

# Expose Port for SSH (22), JupyterLab (8888), Streamlit (8501) (optional, change if needed)
EXPOSE 22
EXPOSE 8888
EXPOSE 8501

## For auto Start Streamlit Service as Docker Image start running
ENTRYPOINT ["streamlit", "run", "homepage.py", "--server.port=8501", "--server.address=0.0.0.0"]

##### Notes
### run the Docker Image Ubuntu 22.04
# Run command on any directory : sudo docker run -d --privileged=true --name ubuntu_python_git -p 2222:22 -p 2888:8888 -p 2501:8501 -v /data:/data ubuntu_python_git

### run openssh service
# Run command on directory /data/ubuntu-python-streamlit : sudo nohup /usr/sbin/sshd -D &
