<p align="center">
  <img src="https://user-images.githubusercontent.com/39219943/152391114-d66ac115-5d00-49fd-99d8-68762624c797.PNG" alt="Offsite logo" height="150px" width="450px"/>
</p>

<h3 align="center"> <i> Move your downloads offsite </i> </h3>
<hr/>

Offsite is a simple downloader that can be hosted on the cloud.
It can then be used to download files or [torrents](#torrent) easily and can also stream supported video formats directly on your browser.

### How does this help me?

Sometimes even when we have a good internet connection certain downloads are extremely slow this often happens due to the geographical location of the server from which the files are being downloaded or due to some other reason.

This is where offsite can help, it downloads the files for you and since the app can be hosted on some cloud server it often downloads files faster than your internet connection.

Once offsite downloads the file(s) it can then directly serve the file(s) to you.
So now instead of downloading the file(s) slowly from that server you let offsite download it at higher speeds and then you can download the same file(s) from offsite at the maximum speeds that your ISP provides.

![Capture](https://user-images.githubusercontent.com/39219943/152670275-d8dcaba4-7ac3-41aa-8a22-ee1a042440fe.PNG)

## An example:

A certain file with a size of 5 GB was taking a long time to download on your computer and only gave speeds up to 500 kB/s.
You decided to download this file using offsite and found that offsite was able to download it at speeds around 4 MB/s

After the offsite download was complete you started to download the file from offsite's server and was able to do so at a much higher speed say 3 MB/s.

So the original download would have taken you ~2.778 hours when downloading at 500 kB/s

Now with offsite, it would take only ~49 minutes to download the same file, here's how...

Offsite downloads the file in 21 minutes @ 4 MB/s.
You download the file from offsite in 28 minutes @ 3 MB/s.

---

But wait, that's not all...

Say a certain video is buffering even after you have a stable internet connection.
Offsite might help, just paste the video link and offsite will download it for you.

If the file is in a compatible playable format like mp4, WebM and Ogg then you can directly stream it without having to download it, you can even try to stream it while offsite is still downloading the file.

*(Try firefox while streaming videos from offsite if you face issues with chrome or any other chromium based browsers)*

Some other features that offsite offers are...

* **Resumable/partial download** - Downloads can be paused and resumed.
* **Streaming** - Both normal downloads, as well as torrent downloads with mp4, WebM or Ogg files, can be streamed directly on the browser
* **Customizable torrent downloads** - Offsite uses the [transmission](https://transmissionbt.com/ "transmission") torrent client under the hood so you can easily control your torrent downloads for example choose which files you want to download in a torrent.
* **Simple UI with real-time updates** - Offsite has a very simple UI but shows real-time updates about your downloads like download speed, ETA, status, etc.


*To use this app read the instructions in the [installation](#installation) section.*

## Screenshots

**Downloading files**
![downloading](https://user-images.githubusercontent.com/39219943/152671444-09aea081-50e4-43e3-bdae-ac865cf52bb3.PNG)

**Streaming a video**
![streaming](https://user-images.githubusercontent.com/39219943/152671449-2df5f163-9e2f-4632-8094-f90cb08fdddc.PNG)

**Downloading Torrents**
![Capture](https://user-images.githubusercontent.com/39219943/152672017-448c2d2a-3a42-481b-adaf-f2e2287d4a67.PNG)

**Download/Stream individual torrent files**
![Capture](https://user-images.githubusercontent.com/39219943/152672058-e68c3aac-2d8c-4c38-adc1-eab1d564ef56.PNG)

**Control torrent downloads through the transmission torrent client web UI**
![Capture](https://user-images.githubusercontent.com/39219943/152672151-d4741d99-16c6-41cf-8466-fb6d6329028f.PNG)

<a name="torrent"></a>
## Torrent Downloads

Offsite uses the opensource bitTorrent client [transmission](https://transmissionbt.com/) for torrent downloads.
(You can find a script `./install_deps.sh` in this repository that can be used to install the client and additional required dependencies.)

After the torrent has been downloaded Offsite automatically zips the entire downloaded contents so that it can be downloaded as a single file.
You can also stream or download individual files in the torrent.

Offsite exposes the transmission web UI for finer control of torrent downloads.
Using the web UI you can pause torrent downloads, selectively choose files that you want to download, etc.

<a name="installation"></a>
## Installation

**DISCLAIMER: If you choose to use this software do it at your own risk. In no event shall the authors be liable for any claim, damages, data loss, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.**


If you just want to try it locally I recommend using the Docker file included in the repository,

Install [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/)

Then just run `docker-compose up` in the project root.

---

In order to benefit from Offsite, you must deploy your own copy of the server on some cloud environment.

**If you face any issues during deployment please [create an issue](https://github.com/Arp-G/offsite/issues) with the details and I will try to help you out and update this read me if required.**
**Prerequisites**
* Install elixir, refer to [this guide](https://elixir-lang.org/install.html)
* Install Phoenix, refer to [this guide](https://hexdocs.pm/phoenix/installation.html)
* Install Node js, refer to [this page](https://nodejs.org/en/download/)

Deploying your own server is easy and free of cost, keep reading to know how...

To host our backend server you can use any service you like, in the guide we will use [Gigalixir](https://www.gigalixir.com/) which makes it super easy to host elixir web apps for free.

*This repository also contains a docker file if you want to use docker for deployment
Our app does not need any database so that makes things simpler for us.*

* First clone this repository using: `git clone https://github.com/Arp-G/offsite.git`
* Next install the gigalixir client, refer to [this page](https://gigalixir.readthedocs.io/en/latest/getting-started-guide.html) for installation details.
* Make sure you create a free account in gigalixir.com (*Note: One gigalixir account can host only one free app*)
* Create a gigalixir app `APP_NAME=$(gigalixir create)`
* Add a the gigalixir git remote by using the git:remote command `gigalixir git:remote $APP_NAME`
* Create the following configuration variables
  Configurations:
  
  - **SECRET_KEY_BASE** - A secret key base for the backend server. You can easily generate such a key using the command `mix phx.gen.secret`
  
  To protect the offsite client we are using simple [HTTP basic auth](https://en.wikipedia.org/wiki/Basic_access_authentication).
  The following credentials will be required by anyone who tries to use the website.
  
  - **AUTH_USERNAME** - Username for HTTP basic auth
  - **AUTH_PASSWORD** - Passowrd for HTTP basic auth.
 
The above configuration can be set using commands like

```
gigalixir config:set SECRET_KEY_BASE=secretkeybase
gigalixir config:set AUTH_USERNAME=Jhon
gigalixir config:set AUTH_PASSWORD=secretpassword
```

* Now we need to install some additional dependencies for torrent download to work.
  - SSH into your running server by using the command: `gigalixir ps:ssh` (Learn more [here](https://gigalixir.readthedocs.io/en/latest/runtime.html))
  - Run the following script `./install_deps.sh`

*Note this script installs the transmission-torrent client and package for zipping files. It must be run every time after deployment or incase your server gets restarted*

* Now open your application using `gigalixir open`. 
<br/> <br/>
That's all we need!

## Development

Want to contribute? Great!
Feel free to pick up an existing issue or some new feature and I will be happy to review PRs and merge them.

Have questions? Feel free to create an issue [here](https://github.com/Arp-G/offsite/issues).

## License
MIT
