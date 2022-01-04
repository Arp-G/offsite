#!/usr/bin/env node

const commandLineArgs = require('command-line-args');

const Transmission = require('transmission');
const transmission = new Transmission();

// {
//   port: 9091,			// DEFAULT : 9091
//   host: 192.168.1.34,			// DEAFULT : 127.0.0.1
//   username: 'username',	// DEFAULT : BLANK
//   password: 'password'	// DEFAULT : BLANK
// }


getTransmissionStats();

// Get details of all torrents currently queued in transmission app
function getTransmissionStats(){
    transmission.sessionStats(function(err, result){
        if(err){
            console.log(err);
        } else {
            console.log(result);
        }
    });
}
 
// Add a torrent by passing a URL to .torrent file or a magnet link
function addTorrent(url){
    transmission.addUrl(url, {
        "download-dir" : "~/transmission/torrents"
    }, function(err, result) {
        if (err) {
            return console.log(err);
        }
        var id = result.id;
        console.log('Just added a new torrent.');
        console.log('Torrent ID: ' + id);
    });
}
 
// Get various stats about a torrent in the queue
function getTorrentDetails(id) {
    transmission.get(id, function(err, result) {
        if (err) {
            throw err;
        }
        if(result.torrents.length > 0){
        	// console.log(result.torrents[0]);			// Gets all details
        	console.log("Name = "+ result.torrents[0].name);
        	console.log("Download Rate = "+ result.torrents[0].rateDownload/1000);
        	console.log("Upload Rate = "+ result.torrents[0].rateUpload/1000);
        	console.log("Completed = "+ result.torrents[0].percentDone*100);
        	console.log("ETA = "+ result.torrents[0].eta/3600);
        	console.log("Status = "+ getStatusType(result.torrents[0].status));
        }
    });
}
 
function deleteTorrent(id){
    transmission.remove(id, true, function(err, result){
        if (err){
            console.log(err);
        } else {
            transmission.get(id, function(err, result) {
               //err no torrent found...
            });
        }
    });
}
 
// To start a paused / stopped torrent which is still in queue
function startTorrent(id){
    transmission.start(id, function(err, result){});
}
 
// To get list of all torrents currently in queue (downloading + paused)
// NOTE : This may return null if all torrents are in paused state 
function getAllActiveTorrents(){
    transmission.active(function(err, result){
    if (err){
        console.log(err);
    }
    else {
        for (var i=0; i< result.torrents.length; i++){
            console.log(result.torrents[i].id);
            console.log(result.torrents[i].name);
        }
    }
    });
}
 
// Pause / Stop a torrent
function stopTorrent(id){
    transmission.stop(id, function(err, result){});
}
 
// Pause / Stop all torrent
function stopAllActiveTorrents(){
    transmission.active(function(err, result){
    if (err){
        console.log(err);
    }
    else {
        for (var i=0; i< result.torrents.length; i++){
            stopTorrents(result.torrents[i].id);
        }
    }
    });
}
 
// Remove a torrent from download queue
// NOTE : This does not trash torrent data i.e. does not remove it from disk
function removeTorrent(id) {
    transmission.remove(id, function(err) {
        if (err) {
            throw err;
        }
        console.log('torrent was removed');
    });
}
 
// Get torrent state
function getStatusType(type){
    return transmission.statusArray[type]
    if(type === 0){
        return 'STOPPED';
    } else if(type === 1){
        return 'CHECK_WAIT';
    } else if(type === 2){
        return 'CHECK';
    } else if(type === 3){
        return 'DOWNLOAD_WAIT';
    } else if(type === 4){
        return 'DOWNLOAD';
    } else if(type === 5){
        return 'SEED_WAIT';
    } else if(type === 6){
        return 'SEED';
    } else if(type === 7){
        return 'ISOLATED';
    }
}
 