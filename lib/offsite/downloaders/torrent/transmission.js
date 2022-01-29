#!/usr/bin/env node

'use strict';
module.paths.push('/home/arpan/.nvm/versions/node/v16.11.0/lib/node_modules');

const commandLineArgs = require('command-line-args');
const Transmission = require('transmission');
const transmission = new Transmission({
  port: 9091,			       // DEFAULT : 9091
  host: '127.0.0.1',		 // DEFAULT : 127.0.0.1
  username: '',	         // DEFAULT : BLANK
  password: ''	         // DEFAULT : BLANK
});

const optionDefinitions = [
  { name: 'method', type: String },
  { name: 'payload', type: String }
];

const run = async () => {
  const { method, payload } = commandLineArgs(optionDefinitions);
  const parsedPayload = JSON.parse(payload || '{}');

  switch (method) {

    case 'ADD':
      const { magnetUri, path } = parsedPayload;

      return new Promise((resolve, reject) => {
        transmission.addUrl(magnetUri, { "download-dir": path },
          (err, result) => {
            if (err) {
              reject(err);
              return;
            }

            resolve(result.id);
          });
      });

    case 'LIST':
      return new Promise(async (resolve, reject) => {
        transmission.get(async (err, result) => {
          if (err) {
            reject(err);
            return;
          }

          const torrents = {};

          for (let i = 0; i < result.torrents.length; i++) {
            const { id } = result.torrents[i];
            torrents[id] = await getTorrentDetails(id);
          }

          resolve(torrents);
        });
      });

    case 'REMOVE':
      const { id } = parsedPayload;

      return new Promise((resolve, reject) => {
        transmission.remove(id, true, (err, result) => {
          if (err) {
            reject(err);
            return;
          }
          
          resolve(result.id);
        });
      });

    default:
      return Promise.reject('Unsupported method');
  }
};


// Get various stats about a torrent in the queue
const getTorrentDetails = async (id) => {
  return new Promise((resolve, reject) => {
    transmission.get(id, (err, result) => {
      if (err) {
        reject(err);
        return;
      }

      resolve(result.torrents[0])
    });
  })
};

async function test() {
  try {
    const response = await run();
    console.log(JSON.stringify({ success: true, result: response }));
  } catch (err) {
    console.log(JSON.stringify({ success: false, result: err.message || err }));
  }
}

test();

// {
//   "success": true,
//   "result": {
//     "2": {
//       "activityDate": 1642867272,
//       "addedDate": 1642866281,
//       "bandwidthPriority": 0,
//       "comment": "",
//       "corruptEver": 0,
//       "creator": "",
//       "dateCreated": 0,
//       "desiredAvailable": 4194598912,
//       "doneDate": 0,
//       "downloadDir": "/home/arpan/Downloads",
//       "downloadLimit": 100,
//       "downloadLimited": false,
//       "downloadedEver": 931772951,
//       "error": 0,
//       "errorString": "",
//       "eta": 11951,
//       "fileStats": [
//         {
//           "bytesCompleted": 931579351,
//           "priority": 0,
//           "wanted": true
//         },
//         {
//           "bytesCompleted": 358,
//           "priority": 0,
//           "wanted": true
//         },
//         {
//           "bytesCompleted": 53226,
//           "priority": 0,
//           "wanted": true
//         }
//       ],
//       "files": [
//         {
//           "bytesCompleted": 931579351,
//           "length": 5126178263,
//           "name": "The Night House (2020) [2160p] [4K] [WEB] [5.1] [YTS.MX]/The.Night.House.2020.2160p.4K.WEB.x265.10bit.AAC5.1-[YTS.MX].mkv"
//         },
//         {
//           "bytesCompleted": 358,
//           "length": 358,
//           "name": "The Night House (2020) [2160p] [4K] [WEB] [5.1] [YTS.MX]/YIFYStatus.com.txt"
//         },
//         {
//           "bytesCompleted": 53226,
//           "length": 53226,
//           "name": "The Night House (2020) [2160p] [4K] [WEB] [5.1] [YTS.MX]/www.YTS.MX.jpg"
//         }
//       ],
//       "hashString": "14558fc459acf25e95767f8f5fad22a0857b0da9",
//       "haveUnchecked": 16482304,
//       "haveValid": 915150631,
//       "honorsSessionLimits": true,
//       "id": 2,
//       "isFinished": false,
//       "isPrivate": false,
//       "leftUntilDone": 4194598912,
//       "magnetLink": "magnet:?xt=urn:btih:14558fc459acf25e95767f8f5fad22a0857b0da9&dn=The%20Night%20House%20%282020%29%20%5B2160p%5D%20%5B4K%5D%20%5BWEB%5D%20%5B5.1%5D%20%5BYTS.MX%5D&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969%2Fannounce&tr=udp%3A%2F%2F9.rarbg.to%3A2710%2Fannounce&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.cyberia.is%3A6969%2Fannounce&tr=http%3A%2F%2Fp4p.arenabg.com%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.internetwarriors.net%3A1337%2Fannounce",
//       "manualAnnounceTime": -1,
//       "maxConnectedPeers": 50,
//       "metadataPercentComplete": 1,
//       "name": "The Night House (2020) [2160p] [4K] [WEB] [5.1] [YTS.MX]",
//       "peer-limit": 50,
//       "peers": [
//         {
//           "address": "18.185.157.41",
//           "clientIsChoked": true,
//           "clientIsInterested": false,
//           "clientName": "libtorrent (Rasterbar) 1.0.11",
//           "flagStr": "T?EX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": false,
//           "peerIsInterested": false,
//           "port": 8110,
//           "progress": 0,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "45.152.211.223",
//           "clientIsChoked": true,
//           "clientIsInterested": false,
//           "clientName": "libTorrent (Rakshasa) 0.13.6",
//           "flagStr": "uEX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": false,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": true,
//           "port": 33107,
//           "progress": 0.2878,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "46.251.131.76",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TDE",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 25570,
//           "progress": 1,
//           "rateToClient": 9000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "54.201.132.104",
//           "clientIsChoked": true,
//           "clientIsInterested": false,
//           "clientName": "libtorrent (Rasterbar) 1.0.9",
//           "flagStr": "T?E",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": false,
//           "peerIsInterested": false,
//           "port": 8118,
//           "progress": 0,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "72.137.82.48",
//           "clientIsChoked": true,
//           "clientIsInterested": false,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TEX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 50015,
//           "progress": 1,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "81.166.86.144",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "-BI2800-",
//           "flagStr": "TDEH",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 6881,
//           "progress": 1,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "82.158.132.212",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "qBittorrent 4.3.9",
//           "flagStr": "TDEX",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 53874,
//           "progress": 1,
//           "rateToClient": 2000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "92.99.6.75",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TDEH",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 28706,
//           "progress": 1,
//           "rateToClient": 46000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "99.251.80.251",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "BitComet 1.85",
//           "flagStr": "DEX",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": false,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 8242,
//           "progress": 1,
//           "rateToClient": 34000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "177.170.89.32",
//           "clientIsChoked": true,
//           "clientIsInterested": true,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TdEX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 26872,
//           "progress": 1,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "181.142.170.32",
//           "clientIsChoked": true,
//           "clientIsInterested": true,
//           "clientName": "-UW127L-",
//           "flagStr": "TdEX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 6881,
//           "progress": 1,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "185.21.217.29",
//           "clientIsChoked": true,
//           "clientIsInterested": true,
//           "clientName": "libTorrent (Rakshasa) 0.13.8",
//           "flagStr": "dUEX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": false,
//           "isUploadingTo": true,
//           "peerIsChoked": false,
//           "peerIsInterested": true,
//           "port": 32769,
//           "progress": 0.2624,
//           "rateToClient": 0,
//           "rateToPeer": 245000
//         },
//         {
//           "address": "185.149.90.15",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "libTorrent (Rakshasa) 0.13.6",
//           "flagStr": "DuEX",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": false,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": true,
//           "port": 51064,
//           "progress": 0.2804,
//           "rateToClient": 43000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "186.23.175.146",
//           "clientIsChoked": true,
//           "clientIsInterested": true,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TdE",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 56237,
//           "progress": 1,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "190.44.204.18",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "-UW127M-",
//           "flagStr": "TD?EX",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": false,
//           "peerIsInterested": false,
//           "port": 6881,
//           "progress": 0.4022,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "190.163.105.88",
//           "clientIsChoked": true,
//           "clientIsInterested": true,
//           "clientName": "-UW127L-",
//           "flagStr": "TdE",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 6881,
//           "progress": 1,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "202.186.90.135",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TDEH",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 26665,
//           "progress": 1,
//           "rateToClient": 170000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "212.102.57.151",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "Transmission 3.00",
//           "flagStr": "DUEX",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": false,
//           "isUploadingTo": true,
//           "peerIsChoked": false,
//           "peerIsInterested": true,
//           "port": 53398,
//           "progress": 0.318,
//           "rateToClient": 8000,
//           "rateToPeer": 0
//         },
//         {
//           "address": "213.14.149.95",
//           "clientIsChoked": true,
//           "clientIsInterested": false,
//           "clientName": "µTorrent 3.5.5",
//           "flagStr": "TUEX",
//           "isDownloadingFrom": false,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": true,
//           "peerIsChoked": false,
//           "peerIsInterested": true,
//           "port": 62401,
//           "progress": 0,
//           "rateToClient": 0,
//           "rateToPeer": 0
//         },
//         {
//           "address": "220.244.117.3",
//           "clientIsChoked": false,
//           "clientIsInterested": true,
//           "clientName": "BitTorrent 7.0.5",
//           "flagStr": "TDEH",
//           "isDownloadingFrom": true,
//           "isEncrypted": true,
//           "isIncoming": false,
//           "isUTP": true,
//           "isUploadingTo": false,
//           "peerIsChoked": true,
//           "peerIsInterested": false,
//           "port": 31405,
//           "progress": 1,
//           "rateToClient": 51000,
//           "rateToPeer": 0
//         }
//       ],
//       "peersConnected": 20,
//       "peersFrom": {
//         "fromCache": 0,
//         "fromDht": 4,
//         "fromIncoming": 0,
//         "fromLpd": 0,
//         "fromLtep": 0,
//         "fromPex": 12,
//         "fromTracker": 4
//       },
//       "peersGettingFromUs": 3,
//       "peersKnown": 0,
//       "peersSendingToUs": 10,
//       "percentDone": 0.1817,
//       "pieceCount": 1223,
//       "pieceSize": 4194304,
//       "pieces": "wAEUQWAUoAAAAmBAIEAIKkAxBEgACpIYgUMAANEMACSCIEcKAIAgACAAYAEAQCAAAiABAAhAFPKBQQCxg4pIhAACABFUTgAkDBAKAgLgQAYAAJAwAoAQANACDAsABgIIAAISgSxQRRMAEAqIFREAYAgCAgAAAAUJAgAECwKBMAAaAGAlAJgUABkACRBAgAQgACAoChFAAAAC",
//       "priorities": [
//         0,
//         0,
//         0
//       ],
//       "rateDownload": 341000,
//       "rateUpload": 245000,
//       "recheckProgress": 0,
//       "seedIdleLimit": 30,
//       "seedIdleMode": 0,
//       "seedRatioLimit": 2,
//       "seedRatioMode": 0,
//       "sizeWhenDone": 5126231847,
//       "startDate": 1642866884,
//       "status": 4,
//       "torrentFile": "/home/arpan/.config/transmission-daemon/torrents/14558fc459acf25e95767f8f5fad22a0857b0da9.torrent",
//       "totalSize": 5126231847,
//       "trackerStats": [
//         {
//           "announce": "udp://tracker.opentrackr.org:1337/announce",
//           "announceState": 1,
//           "downloadCount": 0,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "udp://tracker.opentrackr.org:1337",
//           "id": 0,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 0,
//           "lastAnnounceResult": "Connection failed",
//           "lastAnnounceStartTime": 0,
//           "lastAnnounceSucceeded": false,
//           "lastAnnounceTime": 1642866973,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "",
//           "lastScrapeStartTime": 0,
//           "lastScrapeSucceeded": true,
//           "lastScrapeTime": 1642866290,
//           "lastScrapeTimedOut": false,
//           "leecherCount": 0,
//           "nextAnnounceTime": 1642867310,
//           "nextScrapeTime": 1642868090,
//           "scrape": "udp://tracker.opentrackr.org:1337/scrape",
//           "scrapeState": 1,
//           "seederCount": 0,
//           "tier": 0
//         },
//         {
//           "announce": "udp://tracker.leechers-paradise.org:6969/announce",
//           "announceState": 1,
//           "downloadCount": 0,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "udp://tracker.leechers-paradise.org:6969",
//           "id": 1,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 0,
//           "lastAnnounceResult": "Connection failed",
//           "lastAnnounceStartTime": 0,
//           "lastAnnounceSucceeded": false,
//           "lastAnnounceTime": 1642866973,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "",
//           "lastScrapeStartTime": 0,
//           "lastScrapeSucceeded": true,
//           "lastScrapeTime": 1642866302,
//           "lastScrapeTimedOut": false,
//           "leecherCount": 0,
//           "nextAnnounceTime": 1642867310,
//           "nextScrapeTime": 1642868110,
//           "scrape": "udp://tracker.leechers-paradise.org:6969/scrape",
//           "scrapeState": 1,
//           "seederCount": 0,
//           "tier": 1
//         },
//         {
//           "announce": "udp://9.rarbg.to:2710/announce",
//           "announceState": 1,
//           "downloadCount": 0,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "udp://9.rarbg.to:2710",
//           "id": 2,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 0,
//           "lastAnnounceResult": "Connection failed",
//           "lastAnnounceStartTime": 0,
//           "lastAnnounceSucceeded": false,
//           "lastAnnounceTime": 1642866973,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "",
//           "lastScrapeStartTime": 0,
//           "lastScrapeSucceeded": true,
//           "lastScrapeTime": 1642866302,
//           "lastScrapeTimedOut": false,
//           "leecherCount": 0,
//           "nextAnnounceTime": 1642867311,
//           "nextScrapeTime": 1642868110,
//           "scrape": "udp://9.rarbg.to:2710/scrape",
//           "scrapeState": 1,
//           "seederCount": 0,
//           "tier": 2
//         },
//         {
//           "announce": "udp://p4p.arenabg.ch:1337/announce",
//           "announceState": 1,
//           "downloadCount": -1,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "udp://p4p.arenabg.ch:1337",
//           "id": 3,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 0,
//           "lastAnnounceResult": "Could not connect to tracker",
//           "lastAnnounceStartTime": 0,
//           "lastAnnounceSucceeded": false,
//           "lastAnnounceTime": 1642866890,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "Could not connect to tracker",
//           "lastScrapeStartTime": 0,
//           "lastScrapeSucceeded": false,
//           "lastScrapeTime": 1642866440,
//           "lastScrapeTimedOut": false,
//           "leecherCount": -1,
//           "nextAnnounceTime": 1642874124,
//           "nextScrapeTime": 1642868280,
//           "scrape": "udp://p4p.arenabg.ch:1337/scrape",
//           "scrapeState": 1,
//           "seederCount": -1,
//           "tier": 3
//         },
//         {
//           "announce": "udp://tracker.cyberia.is:6969/announce",
//           "announceState": 1,
//           "downloadCount": -1,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "udp://tracker.cyberia.is:6969",
//           "id": 4,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 0,
//           "lastAnnounceResult": "Connection failed",
//           "lastAnnounceStartTime": 0,
//           "lastAnnounceSucceeded": false,
//           "lastAnnounceTime": 1642866938,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "Connection failed",
//           "lastScrapeStartTime": 0,
//           "lastScrapeSucceeded": false,
//           "lastScrapeTime": 1642866853,
//           "lastScrapeTimedOut": false,
//           "leecherCount": -1,
//           "nextAnnounceTime": 1642874139,
//           "nextScrapeTime": 1642870460,
//           "scrape": "udp://tracker.cyberia.is:6969/scrape",
//           "scrapeState": 1,
//           "seederCount": -1,
//           "tier": 4
//         },
//         {
//           "announce": "http://p4p.arenabg.com:1337/announce",
//           "announceState": 1,
//           "downloadCount": 0,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "http://p4p.arenabg.com:1337",
//           "id": 5,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 49,
//           "lastAnnounceResult": "Success",
//           "lastAnnounceStartTime": 1642867173,
//           "lastAnnounceSucceeded": true,
//           "lastAnnounceTime": 1642867173,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "",
//           "lastScrapeStartTime": 1642866290,
//           "lastScrapeSucceeded": true,
//           "lastScrapeTime": 1642866290,
//           "lastScrapeTimedOut": false,
//           "leecherCount": 0,
//           "nextAnnounceTime": 1642867303,
//           "nextScrapeTime": 1642868090,
//           "scrape": "http://p4p.arenabg.com:1337/scrape",
//           "scrapeState": 1,
//           "seederCount": 0,
//           "tier": 5
//         },
//         {
//           "announce": "udp://tracker.internetwarriors.net:1337/announce",
//           "announceState": 1,
//           "downloadCount": 0,
//           "hasAnnounced": true,
//           "hasScraped": true,
//           "host": "udp://tracker.internetwarriors.net:1337",
//           "id": 6,
//           "isBackup": false,
//           "lastAnnouncePeerCount": 49,
//           "lastAnnounceResult": "Success",
//           "lastAnnounceStartTime": 1642867228,
//           "lastAnnounceSucceeded": true,
//           "lastAnnounceTime": 1642867228,
//           "lastAnnounceTimedOut": false,
//           "lastScrapeResult": "",
//           "lastScrapeStartTime": 0,
//           "lastScrapeSucceeded": true,
//           "lastScrapeTime": 1642866290,
//           "lastScrapeTimedOut": false,
//           "leecherCount": 36,
//           "nextAnnounceTime": 1642867358,
//           "nextScrapeTime": 1642868090,
//           "scrape": "udp://tracker.internetwarriors.net:1337/scrape",
//           "scrapeState": 1,
//           "seederCount": 44,
//           "tier": 6
//         }
//       ],
//       "trackers": [
//         {
//           "announce": "udp://tracker.opentrackr.org:1337/announce",
//           "id": 0,
//           "scrape": "udp://tracker.opentrackr.org:1337/scrape",
//           "tier": 0
//         },
//         {
//           "announce": "udp://tracker.leechers-paradise.org:6969/announce",
//           "id": 1,
//           "scrape": "udp://tracker.leechers-paradise.org:6969/scrape",
//           "tier": 1
//         },
//         {
//           "announce": "udp://9.rarbg.to:2710/announce",
//           "id": 2,
//           "scrape": "udp://9.rarbg.to:2710/scrape",
//           "tier": 2
//         },
//         {
//           "announce": "udp://p4p.arenabg.ch:1337/announce",
//           "id": 3,
//           "scrape": "udp://p4p.arenabg.ch:1337/scrape",
//           "tier": 3
//         },
//         {
//           "announce": "udp://tracker.cyberia.is:6969/announce",
//           "id": 4,
//           "scrape": "udp://tracker.cyberia.is:6969/scrape",
//           "tier": 4
//         },
//         {
//           "announce": "http://p4p.arenabg.com:1337/announce",
//           "id": 5,
//           "scrape": "http://p4p.arenabg.com:1337/scrape",
//           "tier": 5
//         },
//         {
//           "announce": "udp://tracker.internetwarriors.net:1337/announce",
//           "id": 6,
//           "scrape": "udp://tracker.internetwarriors.net:1337/scrape",
//           "tier": 6
//         }
//       ],
//       "uploadLimit": 100,
//       "uploadLimited": false,
//       "uploadRatio": 0.1296,
//       "uploadedEver": 120794196,
//       "wanted": [
//         1,
//         1,
//         1
//       ],
//       "webseeds": [],
//       "webseedsSendingToUs": 0
//     }
//   }
// }
