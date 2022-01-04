#!/usr/bin/env node

const commandLineArgs = require('command-line-args');
const wget = require('wget-improved');
const throttle_limit = 1000; // 1 second
let lastCall = new Date();


//  node lib/offsite/wget.js --src="https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4" --dest="/tmp/exp.vid"

const optionDefinitions = [
  { name: 'src', type: String },
  { name: 'dest', type: String }
]

const { src, dest } = commandLineArgs(optionDefinitions);
console.log(src, dest);

const download = wget.download(src, dest, {});

download.on('error', function (err) {
  console.log(err);
});
download.on('start', function (fileSize) {
  console.log(fileSize);
});
download.on('end', function (output) {
  console.log(output);
});
download.on('progress', function (progress) {
  if(new Date() - lastCall < throttle_limit) return;
  console.log("progress:" + progress);
  lastCall = new Date();
});

// total number of bytes downloaded
download.on('bytes', function(bytes) {
  if(new Date() - lastCall < throttle_limit) return;
  console.log("bytes:" + bytes);
  lastCall = new Date();
});
