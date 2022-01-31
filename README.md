TODO

* Temp fix: Streaming and browser download wont work( "no file" error) on chrome, works on firefox. - 206 resp
(https://stackoverflow.com/questions/57233053/chrome-fails-to-load-video-if-transferred-with-status-206-partial-content)
* On mount live view security
* Upon torrent download auto tab change due to redirect
* Simplify deps install currently I need to manually ssh and run: `chmod +x install_deps.sh && ./install_deps.sh`
* Dockerize and Readme
* Refactor and explore full features of functional components and slots wiht blog post here: https://fly.io/phoenix-files/function-components/
* Refactor some code areas

Observations:

Video tends to load completely before it can play
Transmission new UI wont work due to content-type not json

Simplify deps install currently I need to manually ssh and run: `chmod +x install_deps.sh && ./install_deps.sh`
Check if this exists: the data from transmission is not good enough, if torrent in paused and started the downloaded bytes goes wrong and eta also
Lots of areas to refactor to clean code: check one module at a time
dockerize and make readme also consider writing a blog

docker build -t offsite .
docker run --network="host" -d --name offsite offsite

* Delete container: `docker rm offsite`
* Check logs: `docker container logs -f --details offsite`
* SSH into the container: `docker exec -it offsite /bin/bash`
* Check resource usage of the container: `docker stats offsite`
