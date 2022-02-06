<p align="center">
  <img src="https://user-images.githubusercontent.com/39219943/152391114-d66ac115-5d00-49fd-99d8-68762624c797.PNG" alt="Offsite logo" height="150px" width="450px"/>
</p>

<h3 align="center"> <i> Move your downloads offsite </i> </h3>
<hr/>

Offsite is a simple downloader which can be hosted on any server on the cloud.
It can then be used to download files or [torrents](#torrent) easily and can also stream supported video formats directly on your browser.

### How does this help me?

Sometimes even when we have a good internet connection certain downloads are extremly slow this often happesn due to the geographical location of the server from which the files are being downloaded or due to some other reason.

This is were offsite can help, it downloads the files for you and since the app can be hosted on some cloud server chances are it will have much higher download speeds than your internet connection.

Once offsite downloads the file then it can then directly serve the file to you.
So now instead of downloading the file slowly from that server you let offsite download it at higher speeds and then you can download the same file from offsite at the maximum speeds that your ISP provides.


![Capture](https://user-images.githubusercontent.com/39219943/152670275-d8dcaba4-7ac3-41aa-8a22-ee1a042440fe.PNG)


But wait, thats not all...

Say a certain video is buffering even after you have a stable internet connection.
Offsite might help, just paste the video link and offsite will download it for you.

If the file is in a compatible playable format like mp4, webM and Ogg then you can directly stream it without having to download it, you can even try to stream it while offsite is still downloading the file.

Some other features that offsite supports are...

* **Resumable/partial download** - Downloads can be paused and resumed.
* **Streaming** - Both normal downloads as well as torrent downloads with mp4, webM or Ogg files can be streamed directly on the browser
* **Customizable torrent downloads** - Offsite uses the [transmission](https://transmissionbt.com/ "transmission") torrent client under the hood so you can easily control your torrents downloads for examples choose which files you want to download in a torrent.
* **Simple UI with realtime updates** - Offsite has a very simple UI but shows realtime updates about your downloads like download speed, ETA, status, etc.
<i>To use this app read the instructions in the [installation](#installation) section.</i>

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
(A script `./install_deps.sh` can be used to install the client and additional required dependencies.)

After the torrent has been downloaded Offsite automatically zips the entire downloaded contents so that it can be downloaded as a single file.
You can also stream or download individual files in the torrent.

Offsite exposes the transmission web UI for finer control of torrent downloads.
Using the web UI you can pause torrent downloads, selectively choose files which you want to download, etc.

<a name="installation"></a>
## Installation

**DISCLAIMER: If you choose to use this software do it at your own risk. In no event shall the authors be liable for any claim, damages, data loss or other liability, wether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.**

In order to benifit from Offsite you must deploy your own copy of the server on some cloud environment.

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
  - **USERNAME** - Your name, the app will greet you with this name
  - **SERVER_PASSWORD** - The hashed server password.
                      In order to login to your server this additional password is required. You can easily generate this password hash running the following command in your    local machine.
                      Suppose you password is "secretpassword", run the following command to generate the password hash.
                      ```
                      mix server_password_hasher secretpassword
                      ```
  - **SECRET_KEY_BASE** - A secret key base for the backend server. You can easily generate such a key using the command `mix phx.gen.secret`
  
  To protect the offsite client we are using simple [HTTP basic auth](https://en.wikipedia.org/wiki/Basic_access_authentication).
  The following credentails will be required by anyone who tries to use the website.
  
  - **AUTH_USERNAME** - Username for HTTP basic auth
  - **AUTH_PASSWORD** - Passowrd for HTTP basic auth.
 
The above configuration can be set using using commands like

```
gigalixir config:set SECRET_KEY_BASE=secretkeybase
gigalixir config:set AUTH_USERNAME=Jhon
gigalixir config:set AUTH_PASSWORD=secretpassword
```

* Now we need to install some addtional dependencies for torrent download to work.
  - SSH into your running server by using the command: `gigalixir ps:ssh` (Learn more [here](https://gigalixir.readthedocs.io/en/latest/runtime.html))
  - Run the following script `./install_deps.sh`

** Note this script installs the transmission-torrent client and package for zipping files. It must be run everytime after deployement or incase your server gets restarted **

* Now open you application using `gigalixir open`
Thats all we need!

## Development

Want to contribute? Great!
Feel free to pick up an exiting issue or some new feature and I will be happy to review PRs and merge them.

Have questions? Feel free to create an issue [here](https://github.com/Arp-G/offsite/issues).

## License
MIT







