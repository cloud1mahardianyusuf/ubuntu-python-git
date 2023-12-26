1.  Clone this repo
2.  Run this command from inside directory ubuntu-python-streamlit<br />
    ```docker build -f Dockerfile .```
3.  Run this command to give "tag" for the docker images
    -  Check docker image id
       ```docker images -a```
    -  Give tag name for docker image<br />
       <img src="images/docker images_.png" height="50" />      
    ```
    eg : docker tag <image id> <repository name>
    
    docker tag 51076e4ef50a ubuntu-python-streamlit
    ```
4.  Run this command to run the docker image<br />
    ```docker run -d --privileged=true --name ubuntu-python-streamlit -p 2022:22 -p 2088:8888 -p 2021:8501 -v /data:/data ubuntu-python-streamlit```
