#!/usr/bin/env node
module.paths.push('/home/arpan/.nvm/versions/node/v16.11.0/lib/node_modules');

const commandLineArgs = require('command-line-args');
const wget = require('wget-improved');
const throttle_limit = 500; // 1 second
let progressLastCall = new Date();
let bytesLastCall = new Date();

//  node lib/offsite/wget.js --src="https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4" --dest="/tmp/exp.vid"

const optionDefinitions = [
  { name: 'src', type: String },
  { name: 'dest', type: String }
]

const { src, dest } = commandLineArgs(optionDefinitions);
const download = wget.download(src, dest, {});

download.on('error', (err) => console.log(`error:${err}`));
download.on('start', (fileSize) => console.log(`start:${fileSize}`));
download.on('end', (output) => console.log(`finish:${output}`));
download.on('progress', (progress) => {
  if ((new Date() - progressLastCall) < throttle_limit) return;
  console.log(`progress:${progress}`);
  progressLastCall = new Date();
});

// total number of bytes downloaded
download.on('bytes', (bytes) => {
  if ((new Date() - bytesLastCall) < throttle_limit) return;
  console.log(`bytes:${bytes}`);
  bytesLastCall = new Date();
});
