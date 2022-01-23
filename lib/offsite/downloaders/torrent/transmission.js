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

      return new Promise((resolve, _reject) => {
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
        transmission.active(async (err, result) => {
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
