TODO

* Streaming and browser download wont work( "no file" error) on chrome, works on firefox.
* On mount live view security
* Simplify deps install currently I need to manually ssh and run: `chmod +x install_deps.sh && ./install_deps.sh`
* Dockerize and Readme
* Refactor some code areas

Observations:

Video tends to load completely before it can play
Transmission new UI wont work due to content-type not json

Simplify deps install currently I need to manually ssh and run: `chmod +x install_deps.sh && ./install_deps.sh`
Check if this exists: the data from transmission is not good enough, if torrent in paused and started the downloaded bytes goes wrong and eta also
Lots of areas to refactor to clean code: check one module at a time
dockerize and make readme also consider writing a blog
